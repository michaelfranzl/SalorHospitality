class AddHistoryPrintToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :history_print, :boolean
  end
end
