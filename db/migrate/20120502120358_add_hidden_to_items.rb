class AddHiddenToItems < ActiveRecord::Migration
  def change
    add_column :items, :hidden, :boolean

  end
end
