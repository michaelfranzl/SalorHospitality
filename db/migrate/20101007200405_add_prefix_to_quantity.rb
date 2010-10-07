class AddPrefixToQuantity < ActiveRecord::Migration
  def self.up
    add_column :quantities, :postfix, :string
    rename_column :quantities, :name, :prefix
  end

  def self.down
    remove_column :quantities, :postfix
    rename_column :quantities, :prefix, :name
  end
end
