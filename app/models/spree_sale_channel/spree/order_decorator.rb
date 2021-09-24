module SpreeSaleChannel
    module Spree
        module OrderDecorator
            def self.prepended(base)
                ::Spree::Order.state_machine.before_transition to: :delivery, do: :create_checkout
            end

            def create_checkout
                SpreeSaleChannel::ShopifyCheckout.new(self).call
            end
        end
    end
end
    
::Spree::Order.prepend SpreeSaleChannel::Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(SpreeSaleChannel::Spree::OrderDecorator)