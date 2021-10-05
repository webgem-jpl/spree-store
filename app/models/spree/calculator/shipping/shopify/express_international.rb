module Spree
    module Calculator::Shipping
        module Shopify
            class ExpressInternational < Base
                def self.description
                    "Shopify Express International"
                end
                def self.title
                    "Express International"
                end
            end
        end
    end
end