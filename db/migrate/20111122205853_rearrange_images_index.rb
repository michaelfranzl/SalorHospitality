class RearrangeImagesIndex < ActiveRecord::Migration
  def self.up
    remove_index :images, [:imageable_type, :imageable_id]
    add_index :images, [:imageable_id, :imageable_type]
  end

  def self.down
    remove_index :images, [:imageable_id, :imageable_type]
    add_index :images, [:imageable_type, :imageable_id]
  end
end
