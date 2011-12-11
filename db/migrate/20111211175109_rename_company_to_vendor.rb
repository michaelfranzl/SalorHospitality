class RenameCompanyToVendor < ActiveRecord::Migration
  def up
    rename_table :companies, :vendors
  end

  def down
    rename_table :vendors, :companies
  end
end
