class AddSkuToModels < ActiveRecord::Migration
  def change
    add_column :articles, :sku, :string
    add_column :quantities, :sku, :string
  end
end
