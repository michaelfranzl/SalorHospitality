class AddPricechangedToItems < ActiveRecord::Migration
  def change
    add_column :items, :price_changed, :boolean
    add_column :items, :price_changed_by, :integer
  end
end
