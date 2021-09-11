class AddPresentationAndSaleChannelToPrototype < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_prototypes, :presentation, :string
    add_column :spree_prototypes, :sale_channel, :boolean
  end
end
