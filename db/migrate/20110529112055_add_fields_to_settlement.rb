class AddFieldsToSettlement < ActiveRecord::Migration
  def self.up
    add_column :settlements, :finished, :boolean
    add_column :settlements, :initial_cash, :float
  end

  def self.down
    remove_column :settlements, :finished
    remove_column :settlements, :initial_cash
  end
end
