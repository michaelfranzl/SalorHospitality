class AddCashToPaymentMethodItems < ActiveRecord::Migration
  def change
    add_column :payment_method_items, :cash, :boolean
  end
end
