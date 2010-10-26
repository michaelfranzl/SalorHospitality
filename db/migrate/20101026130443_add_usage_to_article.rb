class AddUsageToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :usage, :integer, :default => 0
  end

  def self.down
    remove_column :articles, :usage
  end
end
