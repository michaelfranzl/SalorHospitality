class RemoveColumns < ActiveRecord::Migration
  def change
    remove_column :tables, :abbreviation
    remove_column :tables, :description
    remove_column :categories, :tax_id
  end
end
