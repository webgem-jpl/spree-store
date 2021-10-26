module SpreeSaleChannel
    module CheckoutService
        class Manager
            include ErrorHandler
            include Parser
            include ShippingRate
            
            def initialize(order)
                @order = order
            end

            def order
                @order
            end

            def vendor
                #TODO change to vendor model
                @vendor ||= order.line_items[0].variant.sku.split('_')[1]
            end

            def logger
                @logger ||= Rails.logger
            end

            def client
                @client ||= ::Faraday.new(
                    headers: {"Authorization": "Bearer #{ENV['SALE_CHANNEL_TOKEN']}", 
                        "Content-type": "application/json"})
            end

            def create_checkout
                checkout_params = create_checkout_params
                builder = ::ShopifyApi::Checkout::Builder.new(checkout_params)
                builder.validate!
                begin
                    checkout = builder.create_checkout
                rescue ::ShopifyApi::Checkout::Errors::CheckoutError => e
                    handle_checkout_error(e.message)
                end
                save_checkout(checkout)
            end

            def get_shipping_rates
                retrieve_rates_from_cache(order)
            end

            def set_shipping_line
                return unless shopify?
                rate = retrieve_shipping_rate
                begin
                    shipping_line_params = create_shipping_line_params(rate)
                    checkout_builder = ::ShopifyApi::Checkout::Builder.new(shipping_line_params)
                    checkout_builder.validate!
                    checkout = checkout_builder.create_checkout
                rescue ::ShopifyApi::Checkout::Errors::CheckoutError => e
                    handle_checkout_error(e)
                end
                save_checkout(checkout)
            end

            def complete_checkout
                ::ShopifyApi::Checkout::Manager.new(order.checkout).complete_checkout
            end

            def shopify?
                @is_shopify ||= vendor.downcase.end_with?('.myshopify.com')
            end

        private

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
        end
    end
end
