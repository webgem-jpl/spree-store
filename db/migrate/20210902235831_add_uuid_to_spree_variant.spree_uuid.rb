# This migration comes from spree_uuid (originally 20210810201033)
class AddUuidToSpreeVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_variants, :uuid, :uuid
    add_index :spree_variants, :uuid
  end
end
