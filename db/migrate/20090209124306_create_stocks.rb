class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.float :balance
      t.string :unit
      t.string :name
      t.integer :group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :stocks
  end
end
