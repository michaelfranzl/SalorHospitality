class AddColorToPartial < ActiveRecord::Migration
  def self.up
    add_column :partials, :color, :string
  end

  def self.down
    remove_column :partials, :color
  end
end
