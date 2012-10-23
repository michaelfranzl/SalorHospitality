class AddHiddenToPaymentMethodItems < ActiveRecord::Migration
  def change
    add_column :payment_method_items, :hidden, :boolean
    add_column :payment_method_items, :hidden_by, :integer
  end
end
