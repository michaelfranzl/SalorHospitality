class AddPrintQuantityReductionsToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :print_count_reductions, :boolean
  end
end
