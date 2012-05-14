class AddRotateToTable < ActiveRecord::Migration
  def self.up
    add_column :tables, :rotate, :boolean
    change_column :tables, :width_mobile, :integer, :default => 70
    change_column :tables, :height_mobile, :integer, :default => 45
  end

  def self.down
    remove_column :tables, :rotate
  end
end
