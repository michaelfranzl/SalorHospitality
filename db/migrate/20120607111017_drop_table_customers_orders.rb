class DropTableCustomersOrders < ActiveRecord::Migration
  def up
    drop_table :customers_orders
    drop_table :customers_items
  end

  def down
    create_table "customers_items", :id => false, :force => true do |t|
      t.integer "customer_id"
      t.integer "item_id"
    end

    create_table "customers_orders", :id => false, :force => true do |t|
      t.integer "customer_id"
      t.integer "order_id"
    end
  end
end
