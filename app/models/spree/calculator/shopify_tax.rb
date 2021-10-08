 module Spree
    class Calculator::ShopifyTax < Calculator
        def self.description
            "Shopify tax calculator"
        end

        def compute_shipment(shipment)
            Rails.logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            Rails.logger.debug("Calculate shipment")
            return 0 unless shipment.order.checkout.data['shipping_line']
            shipment.order.checkout.data['shipping_line']['tax_lines'].sum{|t| t['price'].to_f}
        end
        
        def compute_line_item(line_item)
            Rails.logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            Rails.logger.debug("Calculate line item")
            variant_id = line_item.variant.sku.split("_")[0].to_i
            line_item = line_item.order.checkout.data['line_items'].detect{|t| t['variant_id'] == variant_id}
            Rails.logger.debug(line_item)
            line_item['tax_lines'].sum{|t| t['price'].to_f}
        end

        def compute_shipping_rate(shipping_rate)
            Rails.logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            Rails.logger.debug("Calculate shipping rate")
            0
        end
    end

end