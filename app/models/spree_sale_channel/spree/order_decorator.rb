module SpreeSaleChannel
    module Spree
        module OrderDecorator
            def self.prepended(base)
                base.has_one :checkout, class_name: 'SpreeSaleChannel::Checkout'
                ::Spree::Order.state_machine.before_transition to: :payment, do: :create_checkout
            end

            def create_checkout
                SpreeSaleChannel::ShopifyCheckout.new(self).call
            end
        end
    end
end
    
::Spree::Order.prepend SpreeSaleChannel::Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(SpreeSaleChannel::Spree::OrderDecorator)