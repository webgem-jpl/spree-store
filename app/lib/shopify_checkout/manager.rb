require 'faraday'
module ShopifyCheckout
    class Manager < Base
        def initialize(order, options={})
            @logger = Rails.logger
            @order = order
            @vendor = order.checkout.vendor
            @shop = ::SpreeSaleChannel::Shop.find_by!(domain: @vendor)
            @token = order.checkout.token
            @options = options.deep_symbolize_keys
        end

        def validate!
            raise Errors::MissingValue.new('Missing "vendor" attribute') unless @vendor.present?
            raise Errors::MissingVendor.new('Shop not found') unless @shop.present?
            raise Errors::MissingValue.new("Missing checkout token") unless @token
        end

        def complete_checkout
            response = ::Faraday.post("https://#{@shop.domain}/admin/api/#{API_VERSION}/checkouts/#{@token}/complete.json", {},
                {'X-Shopify-Access-Token': @shop.token})
            logger.debug(response.status)
            logger.debug(JSON.parse(response.body))
            result = JSON.parse(response.body)
            if response.status == 422
                code = ErrorParser.handle_checkout_error(result)
                if line_items_key = ErrorParser.line_items_with_quantity_error(result)
                    refresh_checkout(line_items_key)
                end
                raise Errors::CheckoutError.new(code)
            else
                result
            end
        end

        def create_checkout_payment
            raise Errors::MissingValue.new("Missing checkout token") unless @token
            response = client.post("/checkouts/#{@token}/payments.json") do |req|
                req.body = payment_params
            end
            result = JSON.parse(response.body)
            if response.status == 422
                raise PaymentError.new(errors: result["errors"])
            else
                result
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

        def payment_params
            @payment_params ||= { 
                payment: {
                    request_details: {
                        ip_address:"123.1.1.1",
                        accept_language:"en-US,en;q=0.8,fr;q=0.6",
                        user_agent:"Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/54.0.2840.98 Safari\/537.36"
                        },
                    amount:"398.00",
                    session_id:"global-9cedb3841ebd4d0d",
                    unique_token:"client-side-idempotency-token"
                }
            }
        end
    end
end