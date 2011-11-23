class DropImageBlobFields < ActiveRecord::Migration
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
