class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.float :balance
      t.string :unit
      t.string :name
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :stocks
  end
end
