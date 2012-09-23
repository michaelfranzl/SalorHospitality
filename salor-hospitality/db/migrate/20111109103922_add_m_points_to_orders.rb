class AddMPointsToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :m_points, :integer
  end

  def self.down
    remove_column :orders, :m_points
  end
end
