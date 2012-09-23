class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.boolean :finished
      t.integer :table_id
      t.integer :user_id
      t.integer :settlement_id

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
