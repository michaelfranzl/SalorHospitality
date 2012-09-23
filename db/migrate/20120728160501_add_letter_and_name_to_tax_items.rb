class AddLetterAndNameToTaxItems < ActiveRecord::Migration
  def change
    add_column :tax_items, :letter, :string
    add_column :tax_items, :surcharge_item_id, :integer
    add_column :tax_items, :name, :string
    add_column :tax_items, :percent, :string
  end
end
