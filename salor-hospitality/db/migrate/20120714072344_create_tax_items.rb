class CreateTaxItems < ActiveRecord::Migration
  def change
    create_table :tax_items do |t|
      t.integer :tax_id
      t.integer :item_id
      t.integer :booking_item_id
      t.integer :order_id
      t.integer :booking_id
      t.integer :settlement_id
      t.float :gro
      t.float :net
      t.float :tax
      t.integer :company_id
      t.integer :vendor_id

      t.timestamps
    end
  end
end
