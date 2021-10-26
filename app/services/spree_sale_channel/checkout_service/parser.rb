module SpreeSaleChannel
    module CheckoutService
        module Parser

            def create_checkout_params
                checkout_params
            end

            def create_shipping_line_params(rate)
                Rails.logger.debug("CREATE SHIPPING LINE PARAMS")
                Rails.logger.debug(rate)
                checkout_params.merge({rate: rate})
            end

            private

            def checkout_params
                @checkout_params ||= {
                    vendor: vendor,
                    order: order_params(order),
                    line_items: line_items_params(order),
                    bill_address: address_params(order.bill_address),
                    ship_address: address_params(order.ship_address)
                }
            end

            # suspect
            def order_params(order)
                vendor = order.line_items[0].variant.sku.split('_')[1]
                order.attributes.merge({vendor: vendor})
            end

            def line_items_params(order)
                line_items = order.line_items.map{|li| li.attributes.merge({sku: li.variant.sku})}
                line_items.map{|li|{ variant_id: li[:sku].split("_")[0], quantity: li[:quantity]}}
            end

            def address_params(address)
                address_attributes = address.attributes
                state_attributes = address.state.attributes
                country_attributes = address.country.attributes
                Rails.logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                Rails.logger.debug(address_attributes)
                params = {
                    first_name: address_attributes['firstname'],
                    last_name: address_attributes['lastname'],
                    phone: address_attributes['phone'],
                    address1: address_attributes['address1'],
                    address2: address_attributes['address2'],
                    city: address_attributes['city'],
                    province: state_attributes['name'],
                    province_code: state_attributes['abbr'], 
                    country: country_attributes['name'],  
                    country_code: country_attributes['iso'],  
                    zip: address_attributes['zipcode']
                }
            end
        end
    end
end