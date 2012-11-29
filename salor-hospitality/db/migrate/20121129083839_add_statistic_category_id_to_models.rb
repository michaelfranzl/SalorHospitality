class AddStatisticCategoryIdToModels < ActiveRecord::Migration
  def change
    add_column :articles, :statistic_category_id, :integer
    add_column :quantities, :statistic_category_id, :integer
    add_column :tax_items, :statistic_category_id, :integer
    add_column :items, :statistic_category_id, :integer
  end
end
