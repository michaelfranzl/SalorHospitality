class AddCurrentSettlementIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_settlement_id, :integer
  end
end
