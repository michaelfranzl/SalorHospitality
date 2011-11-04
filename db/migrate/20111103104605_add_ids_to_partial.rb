class AddIdsToPartial < ActiveRecord::Migration
  def self.up
    add_column :partials, :category_id, :integer
    add_column :partials, :article_id, :string
    add_column :partials, :quantity_id, :string
    add_column :partials, :option_id, :string
  end

  def self.down
    remove_column :partials, :category_id
    remove_column :partials, :article_id
    remove_column :partials, :quantity_id
    remove_column :partials, :option_id
  end
end
