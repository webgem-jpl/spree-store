# This migration comes from spree_product_uuid (originally 20210717164913)
class AddUuidToSpreeProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products, :uuid, :uuid
    add_index :spree_products, :uuid
  end
end
