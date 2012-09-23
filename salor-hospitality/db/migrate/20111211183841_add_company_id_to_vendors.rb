class AddCompanyIdToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :company_id, :integer
  end
end
