# app/controllers/spree/checkout_controller_decorator.rb
module SpreeSaleChannel
    module Spree
      module CheckoutControllerDecorator
        def self.prepended(base)
          base.rescue_from ::SpreeSaleChannel::Errors::AddressError do |exception|
            flash[:error] = exception
            redirect_to checkout_path
          end
          base.rescue_from ::SpreeSaleChannel::Errors::CartError do |exception|
            flash[:error] = exception
            redirect_to checkout_path
          end
        end
      end
    end
  end
  
::Spree::CheckoutController.prepend SpreeSaleChannel::Spree::CheckoutControllerDecorator if ::Spree::CheckoutController.included_modules.exclude?(SpreeSaleChannel::Spree::CheckoutControllerDecorator)