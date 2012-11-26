class AddListByCategoryToTaxes < ActiveRecord::Migration
  def change
    add_column :taxes, :statistics_by_category, :boolean, :default => false
    add_column :taxes, :include_in_statistics, :boolean, :default => false
  end
end
