class AddSortToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :sort, :integer
  end

  def self.down
    remove_column :items, :sort
  end
end
