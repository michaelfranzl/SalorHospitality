class ChangeFinishedOnOrder < ActiveRecord::Migration
  def self.up
    change_column :orders, :finished, :boolean, :default => false
  end

  def self.down
    change_column :orders, :finished, :boolean
  end
end
