class AddTicketFormattingToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :ticket_item_separator, :boolean, :default => true
    add_column :vendors, :ticket_wide_font, :boolean, :default => true
    add_column :vendors, :ticket_tall_font, :boolean, :default => true
  end
end
