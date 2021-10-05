module SpreeSaleChannel
    class CheckoutManager

        def initialize(order)
            @order = order
        end

        def order
            @order
        end

        def logger
            @logger ||= Rails.logger
        end

        def client
            @client ||= ::Faraday.new(
                headers: {"Authorization": "Bearer #{ENV['SALE_CHANNEL_TOKEN']}", 
                    "Content-type": "application/json"})
        end

        def checkout_url
            "#{ENV['SALE_CHANNEL_URL']}/checkout"
        end

        def shopify?
            @is_shopify ||= vendor.downcase.end_with?('.myshopify.com')
        end

        def create_checkout
            response = client.post(checkout_url, checkout_params)
            if response.status == 200
                result = JSON.parse(response.body)
                logger.debug(result)
                token = result['checkout']['token']
                payment_account_id = result['checkout']['shopify_payments_account_id']
                order.checkout.delete if order.checkout
                order.checkout = SpreeSaleChannel::Checkout.create!(
                    token: token,
                    payment_account_id: payment_account_id,
                    order_id: order.id
                )
                order.checkout
            else
                logger.error({status: response.status, message: response.body})
                handle_error(response.body)
            end
        end

        def get_shipping_rates
            retrieve_rates_from_cache(order)
        end

        def set_shipping_line
            return unless shopify?
            token = order.checkout.token
            shipments = ::Spree::Shipment.where(order_id: order.id).includes(shipping_rates: {shipping_method: {calculator: {}}})
            title = shipments.first.shipping_rates.detect{|s| s.selected}.shipping_method.calculator.class.title
            rates_result = get_shipping_rates
            rate = rates_result.detect{|r| r['title'] == title}

            params = {
                shipping_line: rate
            }.to_json

            response = client.post("#{checkout_url}/#{token}/shipping_line", params)
            if response.status == 200
                result = JSON.parse(response.body)
                logger.debug(result)
            else
                logger.error({status: response.status, message: response.body})
                handle_error(response.body)
            end
        end

        def checkout_params
            @checkout_params ||= {
                order: order_params(order),
                line_items: line_items_params(order),
                bill_address: address_params(order.bill_address),
                ship_address: address_params(order.ship_address)
            }.to_json
        end

        def order_params(order)
            vendor = order.line_items[0].variant.sku.split('_')[1]
            order.attributes.merge({vendor: vendor}).to_json
        end

        def line_items_params(order)
            order.line_items.map{|li| li.attributes.merge({sku: li.variant.sku})}.to_json
        end

        def address_params(address)
            address.attributes.merge({state: address.state, country: address.country}).to_json
        end

        def handle_error(result)
            logger.debug(result)
            case result
                when "QUANTITY_ERROR"
                   raise Errors::CartError.new('An item in not in amount enough to fullfill this order.')
                when "LINE_ITEMS_ERROR"
                    logger.error(result)
                    raise Errors::CartError.new('An error occured with your cart.')
                when "BILLING_ZIP_CODE_ERROR"
                    raise Errors::AddressError.new('There is an issue with the zipcode or State of your billing address.')
                when "BILLING_ADDRESS_ERROR"
                    raise Errors::AddressError.new('There is an issue with your billing address.')
                when "SHIPPING_ZIP_CODE_ERROR"
                    raise Errors::AddressError.new('There is an issue with the zipcode or State of your shipping address.')
                when "SHIPPING_ADDRESS_ERROR"
                    raise Errors::AddressError.new('There is an issue with your billing address.')
                when "EMAIL_OR_PHONE_BLANK"
                    raise Errors::AddressError.new('There is an issue with your phone number.')
                when "ERROR"
                    raise CheckoutError.new('An error has occured.')
                    logger.error(result)
            end
        end

    private

        def vendor
            #TODO change to vendor model
            @vendor ||= order.line_items[0].variant.sku.split('_')[1]
        end

        def retrieve_shipping_rates
            raise StandardError.new("Missing checkout") unless checkout = order.checkout
            token = checkout.token
            url = "#{ENV['SALE_CHANNEL_URL']}/checkout/#{token}/shipping_rates.json"
            headers = {'Authorization': "Bearer #{ENV['SALE_CHANNEL_TOKEN']}"}
            response = ::Faraday.post(url, {}, headers)
            if response.status == 200
                result = JSON.parse(response.body)
            else
                error = JSON.parse(response.body) if response.body
                raise Spree::ShippingError.new(error)
            end
            result['shipping_rates']
        end

        def shipping_cache_key(order)
            ship_address = order.ship_address
            contents_hash = Digest::MD5.hexdigest(order.line_items.map {|line_item| line_item.variant.id.to_s + "_" + line_item.quantity.to_s }.join("|"))
            @cache_key = "#{order.number}-#{order.state}-#{ship_address.country.iso}-#{fetch_best_state_from_address(ship_address)}-#{ship_address.city}-#{ship_address.zipcode}-#{contents_hash}".gsub(" ","")
        end

        def fetch_best_state_from_address(address)
            address.state ? address.state.abbr : address.state_name
        end

        def retrieve_rates_from_cache(order)
            Rails.cache.fetch(shipping_cache_key(order)) do
                retrieve_shipping_rates
            end
        end

    end
end
