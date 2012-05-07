class AddToItems < ActiveRecord::Migration
  def change
    add_column :items, :tax_percent, :float
    add_column :items, :tax_amount, :float
    add_column :orders, :tax_amount, :float
    add_column :items, :sum, :float
  end
end
