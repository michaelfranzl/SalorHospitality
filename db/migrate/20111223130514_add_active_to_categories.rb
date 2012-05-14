class AddActiveToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :active, :boolean, :default => true
  end
end
