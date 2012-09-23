class AddHiddenByToItems < ActiveRecord::Migration
  def change
    add_column :items, :hidden_by, :integer
  end
end
