class AddCatidToItem < ActiveRecord::Migration
  def change
    add_column :items, :category_id, :integer
  end
end
