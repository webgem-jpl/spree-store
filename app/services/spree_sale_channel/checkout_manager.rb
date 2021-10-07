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
            builder = ShopifyCheckout::Builder.new(checkout_params)
            builder.validate!
            begin
                checkout = builder.create_checkout
            rescue ::ShopifyCheckout::Errors::CheckoutError => e
                handle_checkout_error(e.message)
            end
            save_checkout(checkout)
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
            @rate = rates_result.detect{|r| r['title'] == title}

            begin
                checkout_builder = ::ShopifyCheckout::Builder.new(checkout_params)
                checkout_builder.validate!
                checkout = checkout_builder.create_checkout
            rescue ::ShopifyCheckout::Errors::CheckoutError => e
                handle_checkout_error(e)
            end
            save_checkout(checkout)
        end

        def save_checkout(checkout)
            Rails.logger.debug(checkout)
            token = checkout['token']
            order.checkout.delete if order.checkout
            order.checkout = SpreeSaleChannel::Checkout.create!(
                    token: token,
                    data: checkout,
                    order_id: order.id,
                    vendor: vendor
                )
            order.checkout
        end

        def checkout_params
            @checkout_params ||= {
                vendor: vendor,
                order: order_params(order),
                line_items: line_items_params(order),
                bill_address: address_params(order.bill_address),
                ship_address: address_params(order.ship_address),
                rates: @rate_params
            }
        end

        def order_params(order)
            vendor = order.line_items[0].variant.sku.split('_')[1]
            order.attributes.merge({vendor: vendor})
        end

        def line_items_params(order)
            order.line_items.map{|li| li.attributes.merge({sku: li.variant.sku})}
        end

        def address_params(address)
            address.attributes.merge({state: address.state, country: address.country})
        end

        def handle_checkout_error(message)
            logger.debug(message)
            case message
                when "QUANTITY_ERROR"
                   raise Errors::CartError.new('An item in not in amount enough to fullfill this order.')
                when "LINE_ITEMS_ERROR"
                    logger.error(message)
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
                else
                    raise Errors::CheckoutError.new('An error has occured.')
                    logger.error(message)
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
            manager = ::ShopifyCheckout::Manager.new(order)
            manager.validate!
            rates_result = manager.get_shipping_rates
            rates_result
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
