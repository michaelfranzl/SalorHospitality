class CreateOptionItems < ActiveRecord::Migration
  def change
    create_table :option_items do |t|
      t.integer :option_id
      t.integer :item_id
      t.integer :order_id
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :hidden
      t.integer :hidden_by
      t.float :price
      t.string :name
      t.integer :count
      t.float :sum

      t.timestamps
    end
  end
end
