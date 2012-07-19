class AddPositionToTables < ActiveRecord::Migration
  def change
    add_column :tables, :position, :integer
  end
end
