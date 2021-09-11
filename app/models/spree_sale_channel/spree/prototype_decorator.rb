module SpreeSaleChannel
    module Spree
      module PrototypeDecorator
        def self.prepended(base)
          base.attribute :presentation
          base.attribute :sale_channel
        end
      end
    end
  end
    
::Spree::Prototype.prepend SpreeSaleChannel::Spree::PrototypeDecorator if ::Spree::Prototype.included_modules.exclude?(SpreeSaleChannel::Spree::PrototypeDecorator)