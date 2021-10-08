require 'faraday'
module Spree
    class ShippingError < StandardError; end
    module Calculator::Shipping
        module Shopify
            class Base < Spree::ShippingCalculator
            
                def compute_package(package)
                    rates_result = retrieve_rates(package)
                    Rails.logger.debug("!!!!!!!!!!!!!!!RATES!!!!!!!!!!!!!!!!!!!!")
                    Rails.logger.debug(rates_result)
                    return nil if rates_result.kind_of?(Spree::ShippingError)
                    return nil unless rates_result.present?
                    rate = select_rate(rates_result)
                    return nil unless rate
                    return rate['price']
                end

                def timing(package)
                    rates_result = retrieve_rates_from_cache(package)
                    return nil if rates_result.kind_of?(Spree::ShippingError)
                    return nil unless rates_result.present?
                    rate = select_rate(rates_result)
                    return nil unless
                    minimum = rate['estimated_time_in_transit'][0]/86400
                    maximum = rate['estimated_time_in_transit'][1]/86400
                    return "#{minimum} to #{maximum} days"
                end

                def select_rate(rates)
                    rates.detect{|r| r['title'] == self.class.title}
                end

                def available?(package)
                    true
                end

                def retrieve_rates(package)
                    order = package.order
                    checkout_manager = ::SpreeSaleChannel::CheckoutManager.new(order)
                    checkout_manager.get_shipping_rates
                end
            end
        end
    end
end