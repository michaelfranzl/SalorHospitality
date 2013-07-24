class AddStartByUserIdToSettlements < ActiveRecord::Migration
  def change
    add_column :settlements, :start_by_user_id, :integer
    add_column :settlements, :stop_by_user_id, :integer
  end
end
