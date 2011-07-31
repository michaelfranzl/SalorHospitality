class ChangeCacheLength < ActiveRecord::Migration
  def self.up
    change_column :companies, :cache, :text, :limit => 500000
  end

  def self.down
    change_column :companies, :cache, :text
  end
end
