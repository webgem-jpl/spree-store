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

        def call
            response = create_checkout
            logger.debug(response)
            response
        end

        def params
            @params ||= {
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

        def create_checkout
            logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!CREATE CHECKOUT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            response = client.post(checkout_url, params)
            if response.status == 200
                logger.debug(response.body)
                result = JSON.parse(response.body)
                logger.debug(result)
                token = result['checkout']['token']
                logger.debug(token)
                payment_account_id = result['checkout']['shopify_payments_account_id']
                order.checkout.delete if order.checkout
                order.checkout = SpreeSaleChannel::Checkout.create!(
                    token: token,
                    payment_account_id: payment_account_id,
                    order_id: order.id
                )
                result
            else
                logger.error({status: response.status, message: response.body})
                handle_error(response.body)
                false
            end
        end

        def handle_error(result)
            case result['code']
                when "QUANTITY_ERROR"
                    order.errors.add(:base, 'An item in not in amount enough to fullfill this order.')
                when "LINE_ITEMS_ERROR"
                    logger.error(result)
                    order.errors.add(:base, 'An error occured with your cart.')
                when "BILLING_ZIP_CODE_ERROR"
                    order.errors.add(:base, 'There is an issue with the zipcode or State of your billing address.')
                when "BILLING_ADDRESS_ERROR"
                    order.errors.add(:base, 'There is an issue with your billing address.')
                when "SHIPPING_ZIP_CODE_ERROR"
                    order.errors.add(:base, 'There is an issue with the zipcode or State of your shipping address.')
                when "SHIPPING_ADDRESS_ERROR"
                    order.errors.add(:base, 'There is an issue with your billing address.')
                when "ERROR"
                    logger.error(result)
            end
        end
    end
end
