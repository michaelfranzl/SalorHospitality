class AddOneTicketPerPieceToVendorPrinters < ActiveRecord::Migration
  def change
    add_column :vendor_printers, :one_ticket_per_piece, :boolean
  end
end
