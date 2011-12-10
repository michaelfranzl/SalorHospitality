class RemoveCategoryIdFromOptions < ActiveRecord::Migration
  def self.up
    remove_column :options, :category_id
  end

  def self.down
    add_column :options, :category_id, :integer
  end
end
