module SpreeSaleChannel
    class Shop < ApplicationRecord
        has_many :products, class_name: "Spree::Product"
    end
end