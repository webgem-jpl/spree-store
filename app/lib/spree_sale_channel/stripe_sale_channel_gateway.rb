require 'faraday'
module SpreeSaleChannel
    class StripeSaleChannelGateway < ::Spree::Gateway

        attr_accessor :secret_key
        attr_accessor :publishable_key
        attr_accessor :server
        attr_accessor :test_mode

        preference :secret_key, :string
        preference :publishable_key, :string

        def provider_class
            SpreeSaleChannel::StripeSaleChannelGateway
        end

        def payment_source_class
            ::Spree::CreditCard
        end
        
        def method_type
            'stripe-sale-channel'
        end

        def logger
            @logger ||= Logger.new(STDOUT)
        end

        def purchase(amount, source, options = {})
            logger.debug("!!!!!!!!!!!!!!!!PURCHASE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            #create_token = create_token(payments_account_id)
            credit_card_token = 'credit_cart_token'
            token = source.payments[0].order.checkout.token
            params = create_complete_checkout_params(source, credit_card_token, token)
            result = complete_checkout(token, params)
            ActiveMerchant::Billing::Response.new(false, result, {}, {})
        end
            
        def authorize(amount, source, options = {})
            logger.debug("!!!!!!!!!!!!!!!!AUTHORIZE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            payments_account_id = source.payments[0].order.checkout.payment_account_id
            token = source.payments[0].order.checkout.token
            #create_token = create_token(payments_account_id)
            ActiveMerchant::Billing::Response.new(true, token, {}, {})
        end
            
        def capture(amount, source, options = {})
            logger.debug("!!!!!!!!!!!!!!!!CAPTURE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            #create_token = create_token(payments_account_id)
            credit_card_token = 'credit_cart_token'
            token = source.payments[0].order.checkout.token
            params = create_complete_checkout_params(source, credit_card_token, token)
            result = complete_checkout(token, params)
            ActiveMerchant::Billing::Response.new(false, result, {}, {})
        end

        def complete_checkout(token, params)
            logger.debug("!!!!!!!!!!!!!!!!!!!!COMPLETE CHECKOUT!!!!!!!!!!!!!!")
            url = "#{ENV['SALE_CHANNEL_URL']}/checkout/#{token}/complete"
            headers = {'Authorization': "Bearer #{ENV['SALE_CHANNEL_TOKEN']}"}
            response = ::Faraday.post(url, params, headers)
            result = JSON.parse(response.body)
            if response.status == 200
                logger.debug(result)
                result
            else
                handle_error(result)
            end
        end

            #TODO change add checkout data on source
        def create_complete_checkout_params(source, credit_card_token , token)
            payment_account_id = source.payments[0].order.checkout.payment_account_id
            vendor = source.payments[0].order.line_items[0].variant.sku.split('_')[1]
            {
                credit_cart_token: credit_card_token,
                payment_account_id: payment_account_id,
                vendor: vendor
            }
        end

        def create_token(payments_account_id)
            url = 'https://api.stripe.com/v1/tokens'
            body = create_payment_method_data(payment_method)
            headers = {'Authentication': "Basic #{preferred_secret_key}",
                         'Stripe-Account': "#{shopify_payments_account_id}"}
            response = ::Faraday.post(url, body, headers)
            result = JSON.parse(response.body)
            if response.status == 200
                logger.debug(result)
                result
            else
                handle_error(result)
            end
        end

        def create_payment_method_data(payment_method, options = {})
            post_data = {}
            post_data[:type] = 'card'
            post_data[:card] = {}
            post_data[:card][:number] = payment_method.number
            post_data[:card][:exp_month] = payment_method.month
            post_data[:card][:exp_year] = payment_method.year
            post_data[:card][:cvc] = payment_method.verification_value
            post_data
        end

        def public_preference_keys
            %i[publishable_key test_mode]
        end

        def handle_error(result)
            raise StandardError.new(result)
        end
    end
end