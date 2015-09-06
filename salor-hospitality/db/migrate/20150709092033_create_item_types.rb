class CreateItemTypes < ActiveRecord::Migration
  def change
    create_table :item_types do |t|
      t.string :name
      t.string :behavior
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :hidden
      t.datetime :hidden_at
      t.integer :hidden_by

      t.timestamps
    end
    
    add_column :articles, :item_type_id, :integer
    add_column :items, :item_type_id, :integer
  end
end
