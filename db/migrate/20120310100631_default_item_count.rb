class DefaultItemCount < ActiveRecord::Migration
  def up
    change_column :items, :count, :integer, :default => 1
  end

  def down
    change_column :items, :count, :integer
  end
end
