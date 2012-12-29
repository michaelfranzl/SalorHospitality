class AddIdHashToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :hash_id, :string
  end
end
