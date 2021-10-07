module ShopifyCheckout
    class Base 
        def refresh_checkout(line_items_key)
            updated_line_items = line_items_key.each{|li| get_inventory_level(@line_items[li].variant_id)}

        end

        def get_inventory_level(variant_id)
            # TODO Get variant inventory from sale channel
            # update inventory
        end
    end
end