class AddSettlementAndCcIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :settlement_id, :integer
    add_column :items, :cost_center_id, :integer
  end
end
