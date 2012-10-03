class AddMoreItemIndexes < ActiveRecord::Migration
  def up
    add_index :items, :count
    add_index :items, :company_id
    add_index :items, :vendor_id
    add_index :items, :preparation_count
    add_index :items, :delivery_count
    add_index :items, :preparation_user_id
    add_index :items, :delivery_user_id
    add_index :items, :hidden
    add_index :items, :category_id
    add_index :items, :refunded
    add_index :items, :settlement_id
    add_index :items, :cost_center_id
  end

  def down
    remove_index :items, :count
    remove_index :items, :company_id
    remove_index :items, :vendor_id
    remove_index :items, :preparation_count
    remove_index :items, :delivery_count
    remove_index :items, :preparation_user_id
    remove_index :items, :delivery_user_id
    remove_index :items, :hidden
    remove_index :items, :category_id
    remove_index :items, :refunded
    remove_index :items, :settlement_id
    remove_index :items, :cost_center_id
  end
end
