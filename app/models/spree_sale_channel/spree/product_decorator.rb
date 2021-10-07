module SpreeSaleChannel
    module Spree
        module ProductDecorator
            def self.prepended(base)
                base.belongs_to :shop, class_name: 'SpreeSaleChannel::Shop'
            end

        end
    end
end
    
::Spree::Product.prepend SpreeSaleChannel::Spree::ProductDecorator if ::Spree::Product.included_modules.exclude?(SpreeSaleChannel::Spree::ProductDecorator)