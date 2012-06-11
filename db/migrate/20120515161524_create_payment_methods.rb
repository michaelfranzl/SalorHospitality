class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.string :name
      t.float :amount
      t.integer :order_id

      t.timestamps
    end
  end
end
