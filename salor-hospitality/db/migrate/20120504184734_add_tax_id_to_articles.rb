class AddTaxIdToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :tax_id, :integer
  end
end
