class AddMinCountToItems < ActiveRecord::Migration
  def change
    add_column :items, :min_count, :integer
  end
end
