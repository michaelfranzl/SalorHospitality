class AddCopiesToVendorPrinter < ActiveRecord::Migration
  def self.up
    add_column :vendor_printers, :copies, :integer, :default => 1
  end

  def self.down
    remove_column :vendor_printers, :copies
  end
end
