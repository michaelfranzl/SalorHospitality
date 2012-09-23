class RemoveTableItemPrintoptions < ActiveRecord::Migration
  def up
    drop_table :items_printoptions
    remove_column :items, :priority
  end
  def down
    create_table :items_printoptions
    add_column :items, :priority, :integer
  end
end
