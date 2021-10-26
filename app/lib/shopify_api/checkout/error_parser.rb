module ShopifyApi
    module Checkout
        module ErrorParser
            def self.line_items_with_quantity_error(result)
                if line_items = result['errors']['line_items'] && result['errors']['line_items'].map do |k,v| 
                        k if v['quantity'].present?
                    end
                    return line_items
                end
            end

            def self.handle_checkout_error(result)
                Rails.logger.debug(result)
                code = result['errors']             if result['errors']
                code = "LINE_ITEMS_ERROR"           if result['errors']['line_items']
                code = "QUANTITY_ERROR"             if result['errors']['line_items'] && result['errors']['line_items'].select{|k,v| v['quantity'].present?}
                code = "BILLING_ADDRESS_ERROR"      if result['errors']['billing_address']
                code = "BILLING_ZIP_CODE_ERROR"     if result['errors']['billing_address'] && result['errors']['billing_address']['zip']
                code = "SHIPPING_ADDRESS_ERROR"     if result['errors']['shipping_address']
                code = "SHIPPING_ZIP_CODE_ERROR"    if result['errors']['shipping_address'] && result['errors']['shipping_address']['zip']
                code = "EMAIL_ERROR"                if result['errors']['email']
                code = "EMAIL_OR_PHONE_BLANK"       if result['errors']['email'] && result['errors']['email'][0]['code']=='email_or_phone_blank'
                code = "MISSING TRANSACTION"        if result['errors']['base'] && result['errors']['base'].first['code'] == "missing_transactions"
                code = 'EMAIL_OR_PHONE_BLANK'       if result['errors']["phone"] && result['errors']["phone"].first["code"] == "email_or_phone_blank"

                return code
            end
        end
    end
end