class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :articles, :category_id
    add_index :articles, :position
    add_index :articles, [:name, :description, :price]
    add_index :categories, :tax_id
    add_index :categories, :vendor_printer_id
    add_index :categories, :position
    add_index :categories, :name
    add_index :groups, :name
    add_index :ingredients, :article_id
    add_index :ingredients, :stock_id
    add_index :items, :article_id
    add_index :items, :order_id
    add_index :items, :quantity_id
    add_index :items, :item_id
    add_index :items, :storno_item_id
    add_index :items, :tax_id
    add_index :items, :priority
    add_index :items, :sort
    add_index :options, :option_id
    add_index :options, :name
    add_index :orders, :table_id
    add_index :orders, :user_id
    add_index :orders, :settlement_id
    add_index :orders, :order_id
    add_index :orders, :cost_center_id
    add_index :orders, :tax_id
    add_index :orders, :nr
    add_index :partials, :presentation_id
    add_index :partials, :model_id
    add_index :presentations, :name
    add_index :presentations, :model
    add_index :quantities, :article_id
    add_index :quantities, :position
    add_index :settlements, :user_id
    add_index :stocks, :group_id
    add_index :tables, :user_id
    add_index :tables, :active_user_id
    add_index :users, :role_id
    #add_index :users, :company_id
    add_index :vendor_printers, :company_id
  end

  def self.down
    remove_index :articles, :category_id
    remove_index :articles, :position
    remove_index :articles, [:name, :description, :price]
    remove_index :categories, :tax_id
    remove_index :categories, :vendor_printer_id
    remove_index :categories, :position
    remove_index :categories, :name
    remove_index :groups, :name
    remove_index :ingredients, :article_id
    remove_index :ingredients, :stock_id
    remove_index :items, :article_id
    remove_index :items, :order_id
    remove_index :items, :quantity_id
    remove_index :items, :item_id
    remove_index :items, :storno_item_id
    remove_index :items, :tax_id
    remove_index :items, :priority
    remove_index :items, :sort
    remove_index :options, :option_id
    remove_index :options, :name
    remove_index :orders, :table_id
    remove_index :orders, :user_id
    remove_index :orders, :settlement_id
    remove_index :orders, :order_id
    remove_index :orders, :cost_center_id
    remove_index :orders, :tax_id
    remove_index :orders, :nr
    remove_index :partials, :presentation_id
    remove_index :partials, :model_id
    remove_index :presentations, :name
    remove_index :presentations, :model
    remove_index :quantities, :article_id
    remove_index :quantities, :position
    remove_index :settlements, :user_id
    remove_index :stocks, :group_id
    remove_index :tables, :user_id
    remove_index :tables, :active_user_id
    remove_index :users, :role_id
    #remove_index :users, :company_id
    remove_index :vendor_printers, :company_id

  end
end
