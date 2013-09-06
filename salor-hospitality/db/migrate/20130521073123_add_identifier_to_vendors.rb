class AddIdentifierToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :identifier, :string
  end
end
