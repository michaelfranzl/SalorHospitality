class AddPulseToVendorPrinters < ActiveRecord::Migration
  def change
    add_column :vendor_printers, :pulse, :boolean
  end
end
