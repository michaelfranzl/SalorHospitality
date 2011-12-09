class ModifyImagesTable < ActiveRecord::Migration
  def self.up
    change_table :images do |i|
      i.rename :model, :imageable_type
      i.integer :imageable_id
    end
  end
  def self.down
    change_table :images do |i|
      i.rename :imageable_type, :model
      i.remove :imageable_id
    end
  end
end
