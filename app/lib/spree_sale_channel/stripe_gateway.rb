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


    # Switch on shipping category

    # First - Spree Channel
        # create token
        # authorize amount on token
        # capture amount on token
            # create payment with transaction (credit card number and confirmation number)

    # Second - Sale Channel
        # source = credit card on total payment
        # Sale Channel = before payment - create checkout for each vendor return to spree shopify_payments_account_id
        # Spree - create one payment per vendor
        # Spree create a token for every Shopify vendor, attached to the source
        # Spree send  token and orderID
        # Sale Channel - create one transaction per vendor and return transaction
        # Spree - create one transaction for each checkout with credit card number and confirmation number
        # create one payment fore each transaction

    # Third - Ensure Balance
        # delete initial payment to equal balance zero
        # if one payment failed update order and send email on backorder

    # Fourth - complete order

    # Fourth - bill each vendor for commission as a job
