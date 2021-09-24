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

        def url
            @url ||= "#{ENV['SALE_CHANNEL_URL']}/checkout"
        end

        def payload
            @payload ||= {
                order: order.to_json,
                carts: carts_payload.to_json,
                bill_address: order.bill_address.to_json,
                ship_address: order.ship_address.to_json
            }.to_json
        end

        #TODO to be tested
        def carts_payload
            line_items = order.line_items.map do |li| 
                line = li.attributes.merge({sku: li.variant.sku})
                line = line.merge({vendor: li.variant.sku.split("_")[1]})
                line = line.merge({total: li.total})
                line
            end
            carts = Hash.new()
            line_items.each{|li| carts[li[:vendor]] =  {}}
            carts.each do |k,v|
                carts[k]['line_items'] = line_items.select{|li| li[:vendor] == k}
                carts[k]['total'] = carts[k]['line_items'].sum{|li| li[:total]}
            end
            return carts
        end

        def call
            result = create_checkout
            update_order(result)
        end

        def create_checkout
            logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!CREATE CHECKOUT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            client.post(url, payload)
        end

        def update_order(result)
            logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!UPDATE ORDER!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        end

    end
end