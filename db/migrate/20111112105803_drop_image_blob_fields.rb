class DropImageBlobFields < ActiveRecord::Migration
  def self.up
    change_table :articles do |a|
      a.remove :image
      a.remove :image_content_type
    end
    change_table :categories do |a|
      a.remove :image
      a.remove :image_content_type
    end
    change_table :companies do |a|
      a.remove :image
      a.remove :content_type
    end
    change_table :options do |a|
      a.remove :image
      a.remove :image_content_type
    end
    change_table :pages do |a|
      a.remove :image
      a.remove :image_content_type
    end
    change_table :quantities do |a|
      a.remove :image
      a.remove :image_content_type
    end
  end

  def self.down
    add_column :articles, :image, :binary, :limit => 500000
    add_column :articles, :image_content_type, :string
    add_column :categories, :image, :binary, :limit => 500000
    add_column :categories, :image_content_type, :string
    add_column :companies, :image, :binary, :limit => 500000
    add_column :companies, :content_type, :string
    add_column :options, :image, :binary, :limit => 500000
    add_column :options, :image_content_type, :string
    add_column :pages, :image, :binary, :limit => 500000
    add_column :pages, :image_content_type, :string
    add_column :quantities, :image, :binary, :limit => 500000
    add_column :quantities, :image_content_type, :string
  end
end
