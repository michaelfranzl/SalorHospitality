class AddCustomerdetailsToTables < ActiveRecord::Migration
  def change
    add_column :tables, :request_order, :boolean
  end
end
