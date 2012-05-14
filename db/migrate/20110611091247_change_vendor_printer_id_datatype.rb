class ChangeVendorPrinterIdDatatype < ActiveRecord::Migration
  def self.up
    change_column :categories, :vendor_printer_id, :integer
  end

  def self.down
    change_column :categories, :vendor_printer_id, :string
  end
end
