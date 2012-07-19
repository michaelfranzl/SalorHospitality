class CreatePaymentMethodItems < ActiveRecord::Migration
  def change
    create_table :payment_method_items do |t|
      t.integer :payment_method_id
      t.integer :order_id
      t.float :amount
      t.integer :company_id
      t.integer :vendor_id

      t.timestamps
    end
  end
end
