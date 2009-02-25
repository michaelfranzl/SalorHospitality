class RemoveFormatSortIdFromArticles < ActiveRecord::Migration
  def self.up
    remove_column :articles, :format_sort_id
  end

  def self.down
    add_column :articles, :format_sort_id, :integer
  end
end
