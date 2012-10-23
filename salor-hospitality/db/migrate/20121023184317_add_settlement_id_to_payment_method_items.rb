class AddSettlementIdToPaymentMethodItems < ActiveRecord::Migration
  def change
    add_column :payment_method_items, :settlement_id, :integer
  end
end
