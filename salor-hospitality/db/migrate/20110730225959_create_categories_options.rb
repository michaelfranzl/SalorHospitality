class CreateCategoriesOptions < ActiveRecord::Migration
  def self.up
    create_table :categories_options, :id => false do |t|
      t.references :category
      t.references :option
      t.timestamps
    end
  end

  def self.down
    drop_table :categories_options
  end
end
