class RenameSortToPosition < ActiveRecord::Migration
  def up
    rename_column :items, :sort, :position
    rename_column :articles, :menucard, :active
  end

  def down
    rename_column :items, :position, :sort
    rename_column :articles, :active, :menucard
  end
end
