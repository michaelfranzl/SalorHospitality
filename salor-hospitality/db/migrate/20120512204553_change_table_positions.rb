class ChangeTablePositions < ActiveRecord::Migration
  def up
    change_column :tables, :left, :integer, :default => 50
    change_column :tables, :top, :integer, :default => 50
    change_column :tables, :left_mobile, :integer, :default => 50
    change_column :tables, :top_mobile, :integer, :default => 50
  end

  def down
  end
end
