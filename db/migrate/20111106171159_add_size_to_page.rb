class AddSizeToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :width, :integer
    add_column :pages, :height, :integer
  end

  def self.down
    remove_column :pages, :height
    remove_column :pages, :width
  end
end
