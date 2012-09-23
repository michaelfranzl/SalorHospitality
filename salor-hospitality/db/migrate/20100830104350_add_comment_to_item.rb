class AddCommentToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :comment, :string
  end

  def self.down
    remove_column :items, :comment
  end
end
