module SpreeSaleChannel
    module CheckoutService
        module ShippingRate

            private
            
            def retrieve_shipping_rate
                shipments = ::Spree::Shipment.where(order_id: order.id).
                    includes(shipping_rates: {shipping_method: {calculator: {}}})
                calculator = shipments.first.shipping_rates.detect{|s| s.selected}.shipping_method.calculator
                raise "Calculator must be for Shopify" unless calculator.class.try(:shopify?)
                title = calculator.class.title
                rates_result = get_shipping_rates
                rate = rates_result.detect{|r| r['title'] == title}
                raise "Missing shipping rate" unless rate
                rate
            end

            def retrieve_shipping_rates
                raise StandardError.new("Missing checkout") unless checkout = order.checkout
                token = checkout.token
                manager = ::ShopifyApi::Checkout::Manager.new(checkout)
                manager.validate!
                rates_result = manager.get_shipping_rates
                Rails.logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                Rails.logger.debug(rates_result)
                rates_result
            end

            def shipping_cache_key(order)
                ship_address = order.ship_address
                contents_hash = Digest::MD5.hexdigest(order.line_items.map {|line_item| line_item.variant.id.to_s + "_" + line_item.quantity.to_s }.join("|"))
                @cache_key = "#{order.number}-#{ship_address.country.iso}-#{fetch_best_state_from_address(ship_address)}-#{ship_address.city}-#{ship_address.zipcode}-#{contents_hash}".gsub(" ","")
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
end