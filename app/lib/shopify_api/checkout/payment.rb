require 'faraday'
module ShopifyApi
    module Checkout
        class Payment < Base
            def initialize(checkout, options={})
                @logger = Logger.new(STDOUT)
                @checkout = checkout.data.deep_symbolize_keys
                @vendor = checkout.vendor
                @shop = ::SpreeSaleChannel::Shop.find_by!(domain: @vendor)
                @token = checkout.token
                @options = options.deep_symbolize_keys
            end

            def create_token(source)
                url = 'https://elb.deposit.shopifycs.com/sessions'
                body = token_params(source)
                headers = {'X-Shopify-Access-Token': @shop.token,  "Content-Type": "application/json"}
                response = ::Faraday.post(url, body, headers)
                result = JSON.parse(response.body)
                if response.status == 200
                    logger.debug(result)
                    result
                else
                    handle_error(result)
                end
            end

            def create_payment(session_id)
                @session_id = session_id
                response = Faraday.post("https://#{@shop.domain}/admin/api/#{API_VERSION}/checkouts/#{@token}/payments.json") do |req|
                    req.body = payment_params.to_json
                    req.headers = {'X-Shopify-Access-Token': @shop.token, "Content-Type": "application/json"}
                end
                result = JSON.parse(response.body)
                if response.status == 200
                    result
                elsif response.status == 202
                    result
                else
                    raise StandardError.new({status: response.status, errors: result["errors"]})
                end
            end

            def payment_params
                @payment_params ||= { 
                    payment: {
                        # payment_token: {
                        #     payment_data: @credit_card_token,
                        #     type: "stripe_vault_token" 
                        # },
                        request_details: {
                            ip_address:"123.1.1.1",
                            accept_language:"en-US,en;q=0.8,fr;q=0.6",
                            user_agent:"Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/54.0.2840.98 Safari\/537.36"
                            },
                        amount: @checkout[:payment_due],
                        unique_token: Random.uuid,
                        session_id: @session_id
                        }
                }
            end

            def token_params(payment_method)
                post_data = {}
                post_data[:credit_card] = {}
                post_data[:credit_card][:first_name] = "Julien"
                post_data[:credit_card][:last_name] = "Joe"
                post_data[:credit_card][:number] = payment_method.number
                post_data[:credit_card][:month] = payment_method.month
                post_data[:credit_card][:year] = payment_method.year
                post_data[:credit_card][:verification_value] = payment_method.verification_value
                post_data.to_json
            end
        end
    end
end