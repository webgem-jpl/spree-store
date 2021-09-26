module SpreeSaleChannel
    class StripeGatway < Spree::Gateway

        preference :secret_key, :string
        preference :publishable_key, :string

        def provider_class
            SpreeSaleChannel::StripeGatway
        end

        def payment_source_class
            Spree::CreditCard
        end
        
        def method_type
            'stripe'
        end
        
        def purchase(amount, transaction_details, options = {})
            payments_account_id = options[:order].payment_account_id
            create_token = create_token(payments_account_id)

            ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
        end

        def create_token(payments_account_id)
            url = 'https://api.stripe.com/v1/tokens'
            body = create_payment_method_data(payment_method)
            headers = {'Authentication': "Basic #{preferred_secret_key}",
                         'Stripe-Account': "#{shopify_payments_account_id}"}
            response = Faraday.post(url, body, headers)
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
    end
end