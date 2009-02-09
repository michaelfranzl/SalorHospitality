class CreateCommodities < ActiveRecord::Migration
  def self.up
    create_table :commodities do |t|
      t.integer :count
      t.integer :order_id
      t.integer :commodity_id

      t.timestamps
    end
  end

  def self.down
    drop_table :commodities
  end
end
