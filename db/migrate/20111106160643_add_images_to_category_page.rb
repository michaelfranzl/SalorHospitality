class AddImagesToCategoryPage < ActiveRecord::Migration
  def self.up
    add_column :categories, :image, :binary, :limit => 500000
    add_column :categories, :image_content_type, :string
    add_column :pages, :image, :binary, :limit => 500000
    add_column :pages, :image_content_type, :string
  end

  def self.down
    remove_column :categories, :image
    remove_column :categories, :image_content_type
    remove_column :pages, :image
    remove_column :pages, :image_content_type
  end
end
