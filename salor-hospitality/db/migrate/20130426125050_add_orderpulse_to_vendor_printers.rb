class AddOrderpulseToVendorPrinters < ActiveRecord::Migration
  def change
    add_column :vendor_printers, :pulse_receipt, :boolean
    rename_column :vendor_printers, :pulse, :pulse_tickets
  end
end
