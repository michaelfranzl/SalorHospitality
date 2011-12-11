class AddVendorIdToModels < ActiveRecord::Migration
  def up
    add_column :articles, :vendor_id, :integer
    add_column :categories, :vendor_id, :integer
    add_column :cost_centers, :vendor_id, :integer
    add_column :coupons, :vendor_id, :integer
    add_column :customers, :vendor_id, :integer
    add_column :discounts, :vendor_id, :integer
    add_column :groups, :vendor_id, :integer
    add_column :images, :vendor_id, :integer
    add_column :ingredients, :vendor_id, :integer
    add_column :items, :vendor_id, :integer
    add_column :logins, :vendor_id, :integer
    add_column :options, :vendor_id, :integer
    add_column :orders, :vendor_id, :integer
    add_column :pages, :vendor_id, :integer
    add_column :partials, :vendor_id, :integer
    add_column :presentations, :vendor_id, :integer
    add_column :quantities, :vendor_id, :integer
    add_column :reservations, :vendor_id, :integer
    add_column :roles, :vendor_id, :integer
    add_column :settlements, :vendor_id, :integer
    add_column :stocks, :vendor_id, :integer
    add_column :tables, :vendor_id, :integer
    add_column :taxes, :vendor_id, :integer
    add_column :users, :vendor_id, :integer
    add_column :vendor_printers, :vendor_id, :integer
  end

  def down
    remove_column :articles, :vendor_id
    remove_column :categories, :vendor_id
    remove_column :cost_centers, :vendor_id
    remove_column :coupons, :vendor_id
    remove_column :customers, :vendor_id
    remove_column :discounts, :vendor_id
    remove_column :groups, :vendor_id
    remove_column :images, :vendor_id
    remove_column :ingredients, :vendor_id
    remove_column :items, :vendor_id
    remove_column :logins, :vendor_id
    remove_column :options, :vendor_id
    remove_column :orders, :vendor_id
    remove_column :pages, :vendor_id
    remove_column :partials, :vendor_id
    remove_column :presentations, :vendor_id
    remove_column :quantities, :vendor_id
    remove_column :reservations, :vendor_id
    remove_column :roles, :vendor_id
    remove_column :settlements, :vendor_id
    remove_column :stocks, :vendor_id
    remove_column :tables, :vendor_id
    remove_column :taxes, :vendor_id
    remove_column :users, :vendor_id
    remove_column :vendor_printers, :vendor_id
  end
end
