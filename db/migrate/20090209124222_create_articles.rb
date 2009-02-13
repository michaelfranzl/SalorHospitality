class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :name
      t.string :description
      t.integer :category_id
      t.float :price
      t.boolean :menucard
      t.boolean :blackboard

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
