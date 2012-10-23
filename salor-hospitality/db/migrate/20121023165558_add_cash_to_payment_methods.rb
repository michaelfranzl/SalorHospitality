class AddCashToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :cash, :boolean
  end
end
