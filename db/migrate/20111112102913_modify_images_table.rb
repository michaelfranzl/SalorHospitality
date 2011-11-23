class ModifyImagesTable < ActiveRecord::Migration
  change_table :images do |i|
    i.rename :model, :imageable_type
    i.integer :imageable_id
  end
end
