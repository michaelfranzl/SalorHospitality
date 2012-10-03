class AddOptionItemIndexes < ActiveRecord::Migration
  def up
    add_index :option_items, :vendor_id
    add_index :option_items, :company_id
    add_index :option_items, :hidden
    add_index :option_items, :item_id
    add_index :option_items, :option_id
    add_index :option_items, :order_id
    
    add_index :surcharge_items, :surcharge_id
    add_index :surcharge_items, :booking_item_id
    add_index :surcharge_items, :vendor_id
    add_index :surcharge_items, :company_id
    add_index :surcharge_items, :season_id
    add_index :surcharge_items, :guest_type_id
    add_index :surcharge_items, :hidden
    add_index :surcharge_items, :booking_id
    
    add_index :booking_items, :booking_id
    add_index :booking_items, :hidden
    add_index :booking_items, :vendor_id
    add_index :booking_items, :company_id
    add_index :booking_items, :guest_type_id
    add_index :booking_items, :season_id
    add_index :booking_items, :booking_item_id
    add_index :booking_items, :ui_parent_id
    add_index :booking_items, :ui_id
    add_index :booking_items, :room_id
  end

  def down
    remove_index :option_items, :vendor_id
    remove_index :option_items, :company_id
    remove_index :option_items, :hidden
    remove_index :option_items, :item_id
    remove_index :option_items, :option_id
    remove_index :option_items, :order_id
    
    remove_index :surcharge_items, :surcharge_id
    remove_index :surcharge_items, :booking_item_id
    remove_index :surcharge_items, :vendor_id
    remove_index :surcharge_items, :company_id
    remove_index :surcharge_items, :season_id
    remove_index :surcharge_items, :guest_type_id
    remove_index :surcharge_items, :hidden
    remove_index :surcharge_items, :booking_id
    
    remove_index :booking_items, :booking_id
    remove_index :booking_items, :hidden
    remove_index :booking_items, :vendor_id
    remove_index :booking_items, :company_id
    remove_index :booking_items, :guest_type_id
    remove_index :booking_items, :season_id
    remove_index :booking_items, :booking_item_id
    remove_index :booking_items, :ui_parent_id
    remove_index :booking_items, :ui_id
    remove_index :booking_items, :room_id
  end
end
