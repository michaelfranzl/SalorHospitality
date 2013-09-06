class AddUserIdToPaymentMethodItems < ActiveRecord::Migration
  def change
    add_column :payment_method_items, :user_id, :integer
  end
end
