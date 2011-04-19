class AddColorToTaxes < ActiveRecord::Migration
  def self.up
    add_column :taxes, :color, :string
  end

  def self.down
    remove_column :taxes, :color
  end
end
