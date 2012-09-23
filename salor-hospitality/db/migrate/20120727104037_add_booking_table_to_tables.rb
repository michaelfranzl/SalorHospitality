class AddBookingTableToTables < ActiveRecord::Migration
  def change
    add_column :tables, :booking_table, :boolean
  end
end
