class AddCategoryIdToTaxItems < ActiveRecord::Migration
  def change
    add_column :tax_items, :category_id, :integer
  end
end
