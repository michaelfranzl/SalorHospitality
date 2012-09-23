class AddMobileCoordinatesToTable < ActiveRecord::Migration
  def self.up
    add_column :tables, :left_ipod, :integer
    add_column :tables, :top_ipod, :integer
    add_column :tables, :width_ipod, :integer, :default => 100
    add_column :tables, :height_ipod, :integer, :default => 60
  end

  def self.down
    remove_column :tables, :left_ipod
    remove_column :tables, :top_ipod
    remove_column :tables, :width_ipod
    remove_column :tables, :height_ipod
  end
end
