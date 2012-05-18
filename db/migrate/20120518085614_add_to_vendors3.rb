class AddToVendors3 < ActiveRecord::Migration
  def change
    add_column :vendors, :ticket_display_time_order, :boolean, :default => true
  end
end
