class AddCustomersToTables < ActiveRecord::Migration
  def change
    add_column :tables, :confirmations_pending, :boolean
    add_column :tables, :customer_id, :integer
  end
end
