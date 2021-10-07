class CreateShop < ActiveRecord::Migration[6.1]
  def change
    create_table :shops do |t|
      t.string :domain
      t.string :token
      t.timestamps
    end
    add_index :shops, :domain
  end
end
