class AddScribeToItems < ActiveRecord::Migration
  def change
    add_column :items, :scribe, :text
  end
end
