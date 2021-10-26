# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)

puts "Loading option types"
# Option Type Color
color   = Spree::OptionType.create!(name:"Color", presentation: "Color")
    
red     = Spree::OptionValue.create!(
            name: "Red",
            presentation: "red",
            option_type_id: color.id)

black   = Spree::OptionValue.create!(
            name: "Black",
            presentation: "black",
            option_type_id: color.id)

pink     = Spree::OptionValue.create!(
            name: "Pink",
            presentation: "pink",  
            option_type_id: color.id)

# Option Type Size
size    = Spree::OptionType.create!(name:"Size", presentation: "Size")

small   = Spree::OptionValue.create!(
            name: "Small",
            presentation: "small",
            option_type_id: size.id)

medium  = Spree::OptionValue.create!(
            name: "Medium",
            presentation: "medium",
            option_type_id: size.id)

large   = Spree::OptionValue.create!(
            name: "Large",
            presentation: "large",
            option_type_id: size.id)

puts "Loading prototype"
# Prototype
shirt   = Spree::Prototype.create!(
            name: 'Shirt',
            presentation: 'shirt',
            sale_channel: true
        )

shirt.option_types = [size, color]


# Shopify
# Stock location
puts 'Loading Shopify stock location'
usa = Spree::Country.find_by(name: "United States")
Spree::StockLocation.create!(name:"Shopify", active: true, country_id: usa.id)

# Shipping Category
puts 'Loading Shopify shipping category'
shopify_shipping_category = Spree::ShippingCategory.create!(name:"Shopify")

# Shopify Tax Category
puts 'Loading Shopify tax category'
shopify_tax_category = Spree::TaxCategory.create!(name:"Shopify",
    description:"Tax code that applied for Shopify's sale channel products")

# Shopify TaxRates
puts 'Loading Shopify tax rates'
Spree::Zone.all.each do |zone|
    tax_rate = Spree::TaxRate.new(
        amount: 0.0,
        zone_id: zone.id,
        tax_category_id: shopify_tax_category.id,
        included_in_price: false,
        name: "Taxes",
        show_rate_in_label: false,
    )
    tax_rate.calculator = Spree::Calculator.create!(
        type: "Spree::Calculator::ShopifyTax")
    tax_rate.save!
end

# Shipping Methods
puts 'Loading Shopify shipping methods'
shopify_express = Spree::ShippingMethod.new(
    name: "Shopify Express", display_on: "both",
    tax_category_id: shopify_tax_category.id)
shopify_express.calculator = Spree::Calculator.create!(
    type: "Spree::Calculator::Shipping::Shopify::Express")
shopify_express.zones = Spree::Zone.all
shopify_express.shipping_categories = [shopify_shipping_category]
shopify_express.save!

shopify_express_int = Spree::ShippingMethod.new(
    name: "Shopify Express International", display_on: "both",
    tax_category_id: shopify_tax_category.id)
shopify_express_int.calculator = Spree::Calculator.create!(
    type: "Spree::Calculator::Shipping::Shopify::ExpressInternational")
shopify_express_int.zones = Spree::Zone.all
shopify_express_int.shipping_categories = [shopify_shipping_category]
shopify_express_int.save!

shopify_standard = Spree::ShippingMethod.new(
    name: "Shopify Standard", display_on: "both",
    tax_category_id: shopify_tax_category.id)
shopify_standard.calculator = Spree::Calculator.create!(
        type: "Spree::Calculator::Shipping::Shopify::Standard")
shopify_standard.zones = Spree::Zone.all
shopify_standard.shipping_categories = [shopify_shipping_category]
shopify_standard.save!

shopify_standard_int = Spree::ShippingMethod.new(
    name: "Shopify Standard International", display_on: "both",
    tax_category_id: shopify_tax_category.id)
shopify_standard_int.calculator = Spree::Calculator.create!(
        type: "Spree::Calculator::Shipping::Shopify::StandardInternational")
shopify_standard_int.zones = Spree::Zone.all
shopify_standard_int.shipping_categories = [shopify_shipping_category]
shopify_standard_int.save!

# Payment Methods
puts 'Loading payment methods'
shopify_stripe = Spree::PaymentMethod.new(
    name: "Credit Card",
    type:"SpreeSaleChannel::StripeSaleChannelGateway",
    display_on: "both",
    auto_capture: true)
shopify_stripe.stores = Spree::Store.all
shopify_stripe.save!

