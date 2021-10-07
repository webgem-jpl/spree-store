class AddShopIdOnSpreeProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products, :shop_id, :bigint
  end
end
