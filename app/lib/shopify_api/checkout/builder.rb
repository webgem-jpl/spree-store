require 'faraday'
module ShopifyApi
    module Checkout
        class Builder < Base
            def initialize(params)
                Rails.logger.debug(params)
                checkout = params.deep_symbolize_keys
                @order = checkout[:order]
                @logger = Logger.new(STDOUT)
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
                        line_items: @line_items,
                        billing_address: @bill_address,
                        shipping_address: @ship_address,
                        shipping_line: shipping_line_params,
                        phone: @bill_address[:phone]
                    }
                }
            end
        end
    end
end