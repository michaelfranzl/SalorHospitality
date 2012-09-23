class CustomersOrders < ActiveRecord::Migration
  def self.up
    create_table :customers_orders, :id => false do |t|
      t.references :customer
      t.references :order
    end
    add_column :items, :customer_id, :integer
  end

  def self.down
    drop_table :customers_orders
    remove_column :items, :customer_id
  end
end
