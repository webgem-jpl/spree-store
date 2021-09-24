class Spree::Gateway::SaleChannel < Spree::Gateway
    def provider_class
      Spree::Gateway::SaleChannel
    end
    def payment_source_class
      Spree::CreditCard
    end
  
    def method_type
      'sale_channel'
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
        # Spree - create token for Shopify
        # Sale Channel - create one transaction per vendor and return transaction
        # Spree - create one transaction for each checkout with credit card number and confirmation number
        # create one payment fore each transaction

    # Third - Ensure Balance
        # delete initial payment to equal balance zero
        # if one payment failed update order and send email on backorder

    # Fourth - bill each vendor for commission as a job

    def purchase(amount, transaction_details, options = {})
      ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
    end

    def authorize
        # authorize amount ????
    end

    def capture
    end

    def create_token
        # switch channel account
    end

    def create_payment
    end

  end
  