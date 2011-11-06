class AddImageSizeToPartial < ActiveRecord::Migration
  def self.up
    add_column :partials, :image_size, :integer
  end

  def self.down
    remove_column :partials, :image_size
  end
end
