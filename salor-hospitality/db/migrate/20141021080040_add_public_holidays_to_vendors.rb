class AddPublicHolidaysToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :public_holidays, :text
  end
end
