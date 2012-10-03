class AddCompanyVendorHiddenIndexes < ActiveRecord::Migration
  def up
    add_index :articles, :company_id
    add_index :articles, :vendor_id
    add_index :articles, :hidden
    add_index :quantities, :company_id
    add_index :quantities, :vendor_id
    add_index :quantities, :hidden
    add_index :categories, :company_id
    add_index :categories, :vendor_id
    add_index :categories, :hidden
    add_index :options, :company_id
    add_index :options, :vendor_id
    add_index :options, :hidden
    add_index :users, :company_id
    add_index :users, :hidden
    add_index :tables, :company_id
    add_index :tables, :vendor_id
    add_index :tables, :hidden
    add_index :settlements, :company_id
    add_index :settlements, :vendor_id
    
    add_index :bookings, :company_id
    add_index :bookings, :vendor_id
    add_index :bookings, :hidden
    add_index :surcharges, :company_id
    add_index :surcharges, :vendor_id
    add_index :surcharges, :hidden
    add_index :room_prices, :company_id
    add_index :room_prices, :vendor_id
    add_index :room_prices, :hidden
    add_index :rooms, :company_id
    add_index :rooms, :vendor_id
    add_index :rooms, :hidden
  end

  def down
    remove_index :articles, :company_id
    remove_index :articles, :vendor_id
    remove_index :articles, :hidden
    remove_index :quantities, :company_id
    remove_index :quantities, :vendor_id
    remove_index :quantities, :hidden
    remove_index :categories, :company_id
    remove_index :categories, :vendor_id
    remove_index :categories, :hidden
    remove_index :options, :company_id
    remove_index :options, :vendor_id
    remove_index :options, :hidden
    remove_index :users, :company_id
    remove_index :users, :hidden
    remove_index :tables, :company_id
    remove_index :tables, :vendor_id
    remove_index :tables, :hidden
    remove_index :settlements, :company_id
    remove_index :settlements, :vendor_id
    
    remove_index :bookings, :company_id
    remove_index :bookings, :vendor_id
    remove_index :bookings, :hidden
    remove_index :surcharges, :company_id
    remove_index :surcharges, :vendor_id
    remove_index :surcharges, :hidden
    remove_index :room_prices, :company_id
    remove_index :room_prices, :vendor_id
    remove_index :room_prices, :hidden
    remove_index :rooms, :company_id
    remove_index :rooms, :vendor_id
    remove_index :rooms, :hidden
  end
end
