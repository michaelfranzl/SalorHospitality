class AddStatusToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :preparation_count, :integer
    add_column :items, :delivery_count, :integer
    add_column :items, :preparation_comment, :string
  end

  def self.down
    remove_column :items, :preparation_count
    remove_column :items, :delivery_count
    remove_column :items, :preparation_comment
  end
end

