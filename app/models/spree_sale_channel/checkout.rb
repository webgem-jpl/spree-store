module SpreeSaleChannel
    class Checkout < ApplicationRecord
        belongs_to :order, class_name: "Spree::Order"
    end
end