class AddBrandingToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :branding, :string, :limit => 5000, :default => "--- {}\n"
  end
end
