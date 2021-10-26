module ShopifyApi 
    module Checkout
        API_VERSION = '2021-07'
        class Base 

            def logger
                @logger ||= Rails.logger
            end

            def validate!
                raise Errors::MissingValue.new('Missing "vendor" attribute') unless @vendor.present?
                raise Errors::MissingVendor.new('Shop not found') unless @shop.present?
                raise Errors::MissingValue.new("Missing checkout token") unless @token
            end

            def refresh_checkout(line_items_key)
                updated_line_items = line_items_key.each{|li| get_inventory_level(@line_items[li].variant_id)}
            end
            
        end
    end
end