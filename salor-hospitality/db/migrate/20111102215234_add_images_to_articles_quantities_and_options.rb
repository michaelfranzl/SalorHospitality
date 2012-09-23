class AddImagesToArticlesQuantitiesAndOptions < ActiveRecord::Migration
  def self.up
    add_column :articles, :image, :binary, :limit => 500000
    add_column :articles, :image_content_type, :string
    add_column :quantities, :image, :binary, :limit => 500000
    add_column :quantities, :image_content_type, :string
    add_column :options, :image, :binary, :limit => 500000
    add_column :options, :image_content_type, :string
  end

  def self.down
    remove_column :articles, :image
    remove_column :articles, :image_content_type
    remove_column :quantities, :image
    remove_column :quantities, :image_content_type
    remove_column :options, :image
    remove_column :options, :image_content_type
  end
end
