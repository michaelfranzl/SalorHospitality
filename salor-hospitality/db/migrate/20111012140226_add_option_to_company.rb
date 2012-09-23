class AddOptionToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :use_order_numbers, :boolean, :default => true
  end

  def self.down
    remove_column :companies, :use_order_numbers
  end
end
