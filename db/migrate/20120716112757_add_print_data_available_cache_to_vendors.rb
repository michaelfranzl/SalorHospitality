class AddPrintDataAvailableCacheToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :print_data_available, :boolean
  end
end
