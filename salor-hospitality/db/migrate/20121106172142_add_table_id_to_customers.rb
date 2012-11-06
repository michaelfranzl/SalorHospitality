class AddTableIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :table_id, :integer
  end
end
