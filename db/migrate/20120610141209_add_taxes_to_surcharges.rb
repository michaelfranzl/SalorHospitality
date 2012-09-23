class AddTaxesToSurcharges < ActiveRecord::Migration
  def up
    create_table :surcharge_items do |t|
      t.integer :surcharge_id
      t.integer :booking_item_id
      t.float :amount
      t.integer :vendor_id
      t.integer :company_id
      t.integer :season_id
      t.integer :guest_type_id
      t.boolean :hidden
      t.integer :booking_item_id
      t.string :taxes, :default => "--- {}\n", :limit => 1000
    end
    create_table :tax_amounts do |t|
      t.integer :surcharge_id
      t.integer :tax_id
      t.float :amount
      t.integer :vendor_id
      t.boolean :hidden
      t.integer :company_id
    end
    drop_table :booking_items_surcharges
  end
  def down
    drop_table :surcharge_items
    drop_table :tax_amounts
    create_table :booking_items_surcharges, :id => false do |t|
      t.integer :booking_item_id
      t.integer :surcharge_id
    end
  end
end
