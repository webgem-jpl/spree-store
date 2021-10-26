module SpreeSaleChannel
    module CheckoutService
        module ErrorHandler
            
            private
            def handle_checkout_error(message)
                logger.debug(message)
                case message
                    when "QUANTITY_ERROR"
                    raise Errors::CartError.new('An item in not in amount enough to fullfill this order.')
                    when "LINE_ITEMS_ERROR"
                        logger.error(message)
                        raise Errors::CartError.new('An error occured with your cart.')
                    when "BILLING_ZIP_CODE_ERROR"
                        raise Errors::AddressError.new('There is an issue with the zipcode or State of your billing address.')
                    when "BILLING_ADDRESS_ERROR"
                        raise Errors::AddressError.new('There is an issue with your billing address.')
                    when "SHIPPING_ZIP_CODE_ERROR"
                        raise Errors::AddressError.new('There is an issue with the zipcode or State of your shipping address.')
                    when "SHIPPING_ADDRESS_ERROR"
                        raise Errors::AddressError.new('There is an issue with your billing address.')
                    when "EMAIL_OR_PHONE_BLANK"
                        raise Errors::AddressError.new('There is an issue with your phone number.')
                    else
                        raise Errors::CheckoutError.new('An error has occured.')
                        logger.error(message)
                end
            end
        end
    end
end
# {"base"=>[{"code"=>"locked", "message"=>"Checkout is locked by another process.", "options"=>{}}]}