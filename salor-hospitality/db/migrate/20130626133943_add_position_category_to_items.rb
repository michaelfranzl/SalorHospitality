class AddPositionCategoryToItems < ActiveRecord::Migration
  def change
    add_column :items, :position_category, :integer
  end
end
