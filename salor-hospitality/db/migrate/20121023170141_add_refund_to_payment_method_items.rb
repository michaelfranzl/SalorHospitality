class AddRefundToPaymentMethodItems < ActiveRecord::Migration
  def change
    add_column :payment_method_items, :refunded, :boolean
  end
end
