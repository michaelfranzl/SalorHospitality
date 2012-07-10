class AddImageTypeToImages < ActiveRecord::Migration
  def up
    add_column :images, :image_type, :string, :default => nil
  end

  def down
    remove_column :images, :image_type
  end
end
