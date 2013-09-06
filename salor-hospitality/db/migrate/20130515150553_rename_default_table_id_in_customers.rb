class RenameDefaultTableIdInCustomers < ActiveRecord::Migration
  def change
    rename_column :customers, :table_id, :default_table_id
  end
end
