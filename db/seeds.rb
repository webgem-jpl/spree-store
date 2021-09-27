# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)


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

# Prototype
shirt   = Spree::Prototype.create!(
            name: 'Shirt',
            presentation: 'shirt',
            sale_channel:  true
        )

shirt.option_types = [color, size]
shirt.save!

