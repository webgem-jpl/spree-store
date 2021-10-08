module SpreeSaleChannel
    module Spree
        module OrderDecorator
            def self.prepended(base)
                base.has_one :checkout, class_name: 'SpreeSaleChannel::Checkout'
            end

            def update_line_item_prices!
                create_checkout
                super
            end

            def apply_free_shipping_promotions
                set_shipping_line
                super
            end

            def create_checkout
                Rails.logger.debug("!!!!!!!!!!!!!!!!!!!!CREATE CHECKOUT!!!!!!!!!!!!!!!!!!!!!!!!!")
                ::SpreeSaleChannel::CheckoutManager.new(self).create_checkout
            end
            def set_shipping_line
                ::SpreeSaleChannel::CheckoutManager.new(self).set_shipping_line
            end

        end
    end
end
    
::Spree::Order.prepend SpreeSaleChannel::Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(SpreeSaleChannel::Spree::OrderDecorator)