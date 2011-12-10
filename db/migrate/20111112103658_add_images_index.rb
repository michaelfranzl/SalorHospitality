class AddImagesIndex < ActiveRecord::Migration
  def self.up
    add_index :images, [:imageable_type, :imageable_id]
  end

  def self.down
    remove_index :images, [:imageable_type, :imageable_id]
  end
end
