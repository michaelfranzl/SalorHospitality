class AddRefundItemIdToPaymentMethodItems < ActiveRecord::Migration
  def change
    add_column :payment_method_items, :refund_item_id, :integer
  end
end
