class AddTaxIdToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :tax_id, :integer
  end

  def self.down
    remove_column :orders, :tax_id
  end
end
