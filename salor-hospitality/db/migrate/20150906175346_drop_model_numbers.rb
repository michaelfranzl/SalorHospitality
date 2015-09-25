class DropModelNumbers < ActiveRecord::Migration
  def up
    remove_column :vendors, :use_order_numbers
    remove_column :vendors, :use_booking_numbers
    remove_column :vendors, :use_settlement_numbers
    
    remove_column :vendors, :unused_order_numbers
    remove_column :vendors, :unused_booking_numbers
    remove_column :vendors, :unused_settlement_numbers
    
    remove_column :vendors, :largest_booking_number
   
    rename_column :vendors, :largest_order_number, :largest_invoice_number
  end

  def down
  end
end