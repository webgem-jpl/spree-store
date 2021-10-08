require 'faraday'
module ShopifyCheckout
    class Builder < Base
        def initialize(params)
            checkout = params.deep_symbolize_keys
            @order = checkout[:order]
            @logger = Rails.logger
            @vendor = checkout[:vendor]
            @line_items = checkout[:line_items]
            @bill_address = checkout[:bill_address]
            @ship_address = checkout[:ship_address]
            @rate = checkout[:rate]
            @shop = ::SpreeSaleChannel::Shop.find_by(domain: @vendor)
        end

        def validate!
            raise Errors::MissingValue.new('Missing "order" attribute') unless @order.present?
            raise Errors::MissingValue.new('Missing "vendor" attribute') unless @vendor.present?
            raise Errors::MissingValue.new('Missing "lines items" attribute') unless @line_items.present?
            raise Errors::MissingValue.new('Missing "bill address" attribute') unless @bill_address.present?
            raise Errors::MissingValue.new('Missing "ship address" attribute') unless @ship_address.present?
            raise Errors::MissingVendor.new('Shop not found') unless @shop.present?
        end

        def create_checkout
            Rails.logger.debug(checkout_params)
            response = Faraday.post("https://#{@shop.domain}/admin/api/#{API_VERSION}/checkouts.json") do |req|
                req.body = checkout_params
                req.headers = {'X-Shopify-Access-Token': @shop.token}
            end
            
            if response.status == 422
                result = JSON.parse(response.body)
                logger.debug(result)
                code = ErrorParser.handle_checkout_error(result)
                if line_items_key = ErrorParser.line_items_with_quantity_error(result)
                    refresh_checkout(line_items_key)
                end
                raise Errors::CheckoutError.new(code)
            else
                result = JSON.parse(response.body)
                logger.debug(response.status)
                logger.debug(result)
                return result['checkout']
            end
        end

        def create_line_items_params(line_items)
            line_items.map{|li|{ variant_id: li[:sku].split("_")[0],quantity: li[:quantity]}}
        end

        def create_address_params(address)
        {
            first_name: address[:firstname],
            last_name: address[:lastname],
            phone: address[:phone],
            address1: address[:address1],
            address2: address[:address2],
            city: address[:city],
            province: address[:state][:name],
            province_code: address[:state][:abbr], 
            country: address[:country][:name],  
            country_code: address[:country][:iso],  
            zip: address[:zipcode]
        }      
        end

        def shipping_line_params
            return nil unless @rate
            @shipping_line ||= {
                handle: @rate[:handle],
                price: @rate[:price],
                title: @rate[:title]
            }
        end
        
        def checkout_params
            {
                checkout: {
                    line_items: create_line_items_params(@line_items),
                    billing_address: create_address_params(@bill_address),
                    shipping_address: create_address_params(@ship_address),
                    shipping_line: shipping_line_params,
                    phone: @bill_address[:phone]
                }
            }
        end
    end
end