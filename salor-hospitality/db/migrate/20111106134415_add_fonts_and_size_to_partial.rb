class AddFontsAndSizeToPartial < ActiveRecord::Migration
  def self.up
    add_column :partials, :font, :string
    add_column :partials, :size, :integer
  end

  def self.down
    remove_column :partials, :size
    remove_column :partials, :font
  end
end
