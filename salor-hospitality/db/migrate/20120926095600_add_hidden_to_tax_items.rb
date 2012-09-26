class AddHiddenToTaxItems < ActiveRecord::Migration
  def change
    add_column :tax_items, :hidden, :boolean
    add_column :tax_items, :hidden_by, :integer
  end
end
