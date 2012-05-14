class AddPositionToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :position, :integer
    remove_column :categories, :sort_order
  end

  def self.down
    remove_column :categories, :position
    add_column :categories, :sort_order, :integer
  end
end
