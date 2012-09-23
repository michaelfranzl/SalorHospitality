class AddStuffToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :hidden, :boolean
    add_column :payment_methods, :company_id, :integer
    add_column :payment_methods, :vendor_id, :integer
  end
end
