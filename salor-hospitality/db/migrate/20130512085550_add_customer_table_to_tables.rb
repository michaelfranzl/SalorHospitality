class AddCustomerTableToTables < ActiveRecord::Migration
  def change
    add_column :tables, :customer_table, :boolean
  end
end
