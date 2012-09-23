class AddHiddenToTaxes < ActiveRecord::Migration
  def self.up
    add_column :taxes, :hidden, :boolean
  end

  def self.down
    remove_column :taxes, :hidden
  end
end
