require 'faraday'
module SpreeSaleChannel
    class StripeSaleChannelGateway < ::Spree::Gateway

        attr_accessor :secret_key
        attr_accessor :publishable_key
        attr_accessor :server
        attr_accessor :test_mode

        preference :secret_key, :string
        preference :publishable_key, :string
        preference :test_mode, :boolean

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

        def order
            @order ||= @source.payments[0].order
        end

        def checkout
            @checkout ||= order.checkout
        end

        def payment_account_id
            @payment_account_id ||= checkout.data['shopify_payments_account_id']
        end

        def token
            @token ||= checkout.token
        end

        def purchase(amount, source, options = {})
            @source = source
            logger.debug("!!!!!!!!!!!!!!!!PURCHASE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            Rails.logger.debug(source.inspect)
            Rails.logger.debug(checkout)
            shopify_api = ShopifyApi::Checkout::Payment.new(checkout)
            session = shopify_api.create_token(source)
            if result = shopify_api.create_payment(session['id'])
                ActiveMerchant::Billing::Response.new(true,'success', {}, {})
            else
                ActiveMerchant::Billing::Response.new(false, result, {}, {})
            end
        end
            
        def authorize(amount, source, options = {})
            logger.debug("!!!!!!!!!!!!!!!!AUTHORIZE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            credit_card_token = create_token(payment_account_id)
            ActiveMerchant::Billing::Response.new(true, token, {}, {})
        end
            
        def capture(amount, source, options = {})
            logger.debug("!!!!!!!!!!!!!!!!CAPTURE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            token = token(source)
            params = create_complete_checkout_params(source, credit_card_token, token)
            result = complete_checkout(token, params)
            ActiveMerchant::Billing::Response.new(false, result, {}, {})
        end


            #TODO change add checkout data on source
        def create_complete_checkout_params(source, credit_card_token, token)
            payment_account_id = payment_account_id(source)
            vendor = source.payments[0].order.line_items[0].variant.sku.split('_')[1]
            {
                credit_cart_token: credit_card_token,
                payment_account_id: payment_account_id,
                vendor: vendor
            }
        end

        # def create_token(payment_account_id, source)
        #     Rails.logger.debug(payment_account_id)
        #     url = 'https://api.stripe.com/v1/tokens'
        #     body = create_payment_method_data(source)
        #     headers = {'Authorization': "Bearer #{preferred_secret_key}"}
        #     response = ::Faraday.post(url, body, headers)
        #     result = JSON.parse(response.body)
        #     if response.status == 200
        #         logger.debug(result)
        #         result
        #     else
        #         handle_error(result)
        #     end
        # end


        # def create_payment_method_data(payment_method, options = {})
        #     post_data = {}
        #     post_data[:card] = {}
        #     post_data[:card][:number] = payment_method.number
        #     post_data[:card][:exp_month] = payment_method.month
        #     post_data[:card][:exp_year] = payment_method.year
        #     post_data[:card][:cvc] = payment_method.verification_value
        #     post_data
        # end

        def public_preference_keys
            %i[publishable_key test_mode]
        end

        def handle_error(result)
            raise StandardError.new(result)
        end
    end
end