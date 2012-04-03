class RenameTables < ActiveRecord::Migration

  def change
    drop_table :cash_drawers
    drop_table :cash_registers
    drop_table :coupons
    drop_table :coupons_orders
    drop_table :discounts
    drop_table :discounts_orders
    drop_table :groups
    drop_table :ingredients

    rename_column :items, :price, :base_price
    rename_column :items, :count, :quantity
    rename_column :items, :printed_count, :printed_quantity
    rename_column :items, :item_id, :order_item_id
    rename_column :items, :article_id, :item_id
    rename_column :items, :storno_status, :item_id
    rename_column :items, :storno_item_id, :refund_order_item_id
    rename_column :items, :tax_id, :tax_profile_id
    rename_column :items, :max_count, :max_quantity
    rename_column :items, :preparation_count, :preparation_quantity
    rename_column :items, :delivery_count, :delivery_quantity
    rename_column :items, :user_id, :employee_id
    rename_column :items, :preparation_user_id, :preparation_employee_id
    rename_column :items, :delivery_user_id, :delivery_employee_id
    rename_table :items, :order_items

    rename_column :articles, :price, :base_price
    rename_table :articles, :items

    rename_column :items_options, :item_id, :order_item_id
    remove_column :items_options, :created_at
    remove_column :items_options, :updated_at
    rename_table :items_options, :order_items_options

    rename_column :items_printoptions, :item_id, :order_item_id
    remove_column :items_printoptions, :created_at
    remove_column :items_printoptions, :updated_at
    rename_table :items_printoptions, :order_items_options

    drop_table :logins

    rename_column :orders, :user_id, :employee_id
    rename_column :orders, :tax_id, :tax_profile_id
    rename_column :orders, :storno_sum, :refund_total

    rename_column :quantities, :article_id, :item_id

    rename_column :settlements, :user_id, :employee_id

    drop_table :stocks

    rename_column :tables, :user_id, :employee_id

    rename_column :tables, :user_id, :employee_id
    remove_column :tables, :created_at
    remove_column :tables, :updated_at
    rename_table :tables_users, :tables_employees

    rename_column :percent, :amount
    rename_table :taxes, :tax_profiles


    rename_column :users, :login, :username
    rename_table :users, :employees

    rename_column :user_id, :employee_id
    rename_table :users_vendors, :employees_vendors

    rename_column :categories, :tax_id, :tax_profile_id
    rename_column :categories, :preparation_user_id, :preparation_employee_id

    rename_table :tax, :tax_profiles
  end

end
