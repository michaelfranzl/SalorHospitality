class RemoveProprietaryNames < ActiveRecord::Migration
  def self.up
    rename_column :tables, :left_ipod, :left_mobile
    rename_column :tables, :top_ipod, :top_mobile
    rename_column :tables, :width_ipod, :width_mobile
    rename_column :tables, :height_ipod, :height_mobile
  end

  def self.down
    rename_column :tables, :left_mobile, :left_ipod
    rename_column :tables, :top_mobile, :top_ipod
    rename_column :tables, :width_mobile, :width_ipod
    rename_column :tables, :height_mobile, :height_ipod
  end
end
