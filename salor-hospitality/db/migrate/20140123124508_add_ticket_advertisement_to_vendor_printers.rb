class AddTicketAdvertisementToVendorPrinters < ActiveRecord::Migration
  def change
    add_column :vendor_printers, :ticket_ad, :string, :default => ""
  end
end
