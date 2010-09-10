class AddFoodToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :food, :boolean
  end

  def self.down
    remove_column :categories, :food
  end
end
