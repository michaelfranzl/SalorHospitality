class AddNoteToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :note, :string
  end

  def self.down
    remove_column :orders, :note
  end
end
