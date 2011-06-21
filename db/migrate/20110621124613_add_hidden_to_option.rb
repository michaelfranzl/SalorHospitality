class AddHiddenToOption < ActiveRecord::Migration
  def self.up
    add_column :options, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :options, :hidden
  end
end
