class AddUsageToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :usage, :integer
    remove_column :categories, :food
  end

  def self.down
    remove_column :categories, :usage
    add_column :categories, :food, :integer
  end
end
