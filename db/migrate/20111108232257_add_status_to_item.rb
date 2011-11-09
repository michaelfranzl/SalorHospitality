class AddStatusToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :on_preparation_list, :boolean
    add_column :items, :to_preparation_list, :boolean, :default => true
    add_column :items, :on_delivery_list, :boolean
    add_column :items, :to_delivery_list, :boolean
    add_column :items, :delivered, :boolean
    add_column :items, :finished, :boolean
    add_column :items, :updated, :boolean
    add_column :items, :prepared_count, :integer
    add_column :items, :delivered_count, :integer
    add_column :items, :preparation_comment, :string
  end

  def self.down
    remove_column :items, :on_preparation_list
    remove_column :items, :to_preparation_list
    remove_column :items, :on_delivery_list
    remove_column :items, :to_delivery_list
    remove_column :items, :delivered
    remove_column :items, :prepared_count
    remove_column :items, :delivered_count
    remove_column :items, :finished
    remove_column :items, :updated
    remove_column :items, :preparation_comment
  end
end

