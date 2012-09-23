class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :name
      t.string :format_name
      t.string :format_sort_id
      t.string :format_division
      t.string :description
      t.text :recipe
      t.integer :category_id
      t.float :price
      t.boolean :menucard, :default => true
      t.boolean :blackboard
      t.boolean :waiterpad

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
