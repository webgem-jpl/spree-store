require 'faraday'

module SpreeSaleChannel
    class ShopifyCheckout

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

        def params
            @params ||= {
                order: order_params(order),
                line_items: order.line_items.to_json,
                bill_address: address_params(order.bill_address),
                ship_address: address_params(order.ship_address)
            }.to_json
        end

        def order_params(order, line_items)
            vendor = line_items[0][sku].split('_')[1]
            order.attributes.merge{vendor: vendor}.to_json
        end

        def address_params(address)
            address.attributes.merge({state: address.state, country: address.country}).to_json
        end

        def create_checkout
            logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!CREATE CHECKOUT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            response = client.post(checkout_url, params)
        end

        def update_order(result)
            logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!UPDATE ORDER!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        end

        def call
            response = create_checkout
            logger.debug(response.status)
            logger.debug(response.body)
            update_order(response)
        end

    end
end