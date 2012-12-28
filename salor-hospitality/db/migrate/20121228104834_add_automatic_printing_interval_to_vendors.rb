class AddAutomaticPrintingIntervalToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :automatic_printing_interval, :integer, :default => 31
  end
end
