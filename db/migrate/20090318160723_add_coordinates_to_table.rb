class AddCoordinatesToTable < ActiveRecord::Migration
  def self.up
    add_column :tables, :left, :integer
    add_column :tables, :top, :integer
    add_column :tables, :width, :integer, :default => 70
    add_column :tables, :height, :integer, :default => 45
  end

  def self.down
    remove_column :tables, :left
    remove_column :tables, :top
    remove_column :tables, :width
    remove_column :tables, :height
  end
end
