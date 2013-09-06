class AddActiveCustomerIdToTables < ActiveRecord::Migration
  def change
    add_column :tables, :active_customer_id, :integer
  end
end
