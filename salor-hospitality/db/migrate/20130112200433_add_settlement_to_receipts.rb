class AddSettlementToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :settlement_id, :integer
    add_column :receipts, :settlement_nr, :integer
  end
end
