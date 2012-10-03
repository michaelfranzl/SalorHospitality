class AddMoreOrderIndexes < ActiveRecord::Migration
  def up
    add_index :orders, :finished
    add_index :orders, :print_pending
    add_index :orders, :company_id
    add_index :orders, :vendor_id
    add_index :orders, :hidden
    add_index :orders, :paid
    add_index :orders, :booking_id
  end

  def down
    remove_index :orders, :finished
    remove_index :orders, :print_pending
    remove_index :orders, :company_id
    remove_index :orders, :vendor_id
    remove_index :orders, :hidden
    remove_index :orders, :paid
    remove_index :orders, :booking_id
  end
end
