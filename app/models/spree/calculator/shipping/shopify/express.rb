module Spree
    module Calculator::Shipping
        module Shopify
            class Express < Base
                def self.description
                    "Shopify Express"
                end
                def self.title
                    "Express"
                end
            end
        end
    end
end