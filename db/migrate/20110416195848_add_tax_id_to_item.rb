class AddTaxIdToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :tax_id, :integer
  end

  def self.down
    remove_column :items, :tax_id
  end
end
