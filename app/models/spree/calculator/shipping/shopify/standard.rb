module Spree
    module Calculator::Shipping
        module Shopify
            class Standard < Base
                def self.description
                    "Shopify Standard"
                end
                def self.title
                    "Standard"
                end
            end
        end
    end
end