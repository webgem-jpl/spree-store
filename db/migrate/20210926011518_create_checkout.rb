class CreateCheckout < ActiveRecord::Migration[6.1]
  def change
    create_table :checkouts do |t|
      t.string :token
      t.json :data
      t.bigint :order_id
      t.string :vendor
      t.timestamps
    end
    add_index :checkouts, :order_id
  end
end
