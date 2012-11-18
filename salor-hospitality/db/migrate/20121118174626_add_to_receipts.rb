class AddToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :vendor_id, :integer
    add_column :receipts, :company_id, :integer
    add_column :receipts, :vendor_printer_id, :integer
    add_column :receipts, :bytes_sent, :integer
    add_column :receipts, :bytes_written, :integer
    add_column :receipts, :order_id, :integer
    add_column :receipts, :order_nr, :integer
  end
end
