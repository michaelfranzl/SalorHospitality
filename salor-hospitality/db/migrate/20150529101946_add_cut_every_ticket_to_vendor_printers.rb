class AddCutEveryTicketToVendorPrinters < ActiveRecord::Migration
  def change
    add_column :vendor_printers, :cut_every_ticket, :boolean
  end
end
