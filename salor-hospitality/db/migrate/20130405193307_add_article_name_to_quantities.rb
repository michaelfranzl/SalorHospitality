class AddArticleNameToQuantities < ActiveRecord::Migration
  def change
    add_column :quantities, :article_name, :string
  end
end
