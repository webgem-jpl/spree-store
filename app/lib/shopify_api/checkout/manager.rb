require 'faraday'
module ShopifyApi
    module Checkout
        class Manager < Base
            def initialize(checkout, options={})
                @logger = Logger.new(STDOUT)
                @vendor = checkout.vendor
                @shop = ::SpreeSaleChannel::Shop.find_by!(domain: @vendor)
                @token = checkout.token
                @options = options.deep_symbolize_keys
            end

            def complete_checkout
                response = ::Faraday.post("https://#{@shop.domain}/admin/api/#{API_VERSION}/checkouts/#{@token}/complete.json", {},
                    {'X-Shopify-Access-Token': @shop.token})
                logger.debug(response.status)
                logger.debug(JSON.parse(response.body))
                result = JSON.parse(response.body)
                if response.status == 202
                  Rails.logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                  Rails.logger.debug(response.body)
                elsif response.status == 200
                    result
                else
                    code = ErrorParser.handle_checkout_error(result)
                    raise Errors::CheckoutError.new(code)
                end
            end

            def get_shipping_rates
                raise Errors::MissingValue.new("Missing checkout token") unless @token
                status = 202
                while status == 202
                    response = ::Faraday.get("https://#{@shop.domain}/admin/api/#{API_VERSION}/checkouts/#{@token}/shipping_rates.json", {},
                        {'X-Shopify-Access-Token': @shop.token})
                    status = response.status
                    sleep(0.2) if status == 202
                end
                result = JSON.parse(response.body)
                if status == 200
                    logger.debug(response.status)
                    logger.debug(result)
                else
                    raise Errors::ShippingRate.new(result)
                end
                result["shipping_rates"]
            end
        end
    end
end