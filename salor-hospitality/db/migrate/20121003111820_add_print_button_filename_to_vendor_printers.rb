class AddPrintButtonFilenameToVendorPrinters < ActiveRecord::Migration
  def change
    add_column :vendor_printers, :print_button_filename, :string
  end
end
