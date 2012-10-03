class AddTaxItemIndexes < ActiveRecord::Migration
  def up
    add_index :tax_items, :tax_id
    add_index :tax_items, :item_id
    add_index :tax_items, :booking_item_id
    add_index :tax_items, :order_id
    add_index :tax_items, :booking_id
    add_index :tax_items, :settlement_id
    add_index :tax_items, :company_id
    add_index :tax_items, :vendor_id
    add_index :tax_items, :surcharge_item_id
    add_index :tax_items, :hidden
  end

  def down
    remove_index :tax_items, :tax_id
    remove_index :tax_items, :item_id
    remove_index :tax_items, :booking_item_id
    remove_index :tax_items, :order_id
    remove_index :tax_items, :booking_id
    remove_index :tax_items, :settlement_id
    remove_index :tax_items, :company_id
    remove_index :tax_items, :vendor_id
    remove_index :tax_items, :surcharge_item_id
    remove_index :tax_items, :hidden
  end
end
