class CreateCheckout < ActiveRecord::Migration[6.1]
  def change
    create_table :checkouts do |t|
      t.string :token
      t.string :payment_account_id
      t.integer :order_id
      t.timestamps
    end
    add_index :checkouts, :order_id
  end
end
