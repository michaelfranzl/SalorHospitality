class AddTicketSpaceTopToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :ticket_space_top, :integer, :default => 5
  end
end
