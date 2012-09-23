class AddImageToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :content_type, :string
    add_column :companies, :image, :binary
  end

  def self.down
    remove_column :companies, :image
    remove_column :companies, :content_type
  end
end
