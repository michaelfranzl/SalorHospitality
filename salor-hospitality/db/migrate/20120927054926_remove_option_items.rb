class RemoveOptionItems < ActiveRecord::Migration
  def change
    drop_table :items_options
    drop_table :groups
  end
end
