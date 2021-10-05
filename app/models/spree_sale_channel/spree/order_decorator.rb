module SpreeSaleChannel
    module Spree
        module OrderDecorator
            def self.prepended(base)
                base.has_one :checkout, class_name: 'SpreeSaleChannel::Checkout'
                ::Spree::Order.state_machine.before_transition to: :payment, do: :set_shipping_line
            end

            def set_shipping_line
                ::SpreeSaleChannel::CheckoutManager.new(self).set_shipping_line
            end

        end
    end
end
    
::Spree::Order.prepend SpreeSaleChannel::Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(SpreeSaleChannel::Spree::OrderDecorator)