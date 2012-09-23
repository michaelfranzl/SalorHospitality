class AddColorToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :color, :string
  end

  def self.down
    remove_column :pages, :color
  end
end
