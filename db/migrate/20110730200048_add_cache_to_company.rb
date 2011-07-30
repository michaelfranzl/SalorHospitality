class AddCacheToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :cache, :text
  end

  def self.down
    remove_column :companies, :cache
  end
end
