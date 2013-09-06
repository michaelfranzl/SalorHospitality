class AddBaudrateToVendorPrinters < ActiveRecord::Migration
  def change
    add_column :vendor_printers, :baudrate, :integer, :default => 9600
  end
end
