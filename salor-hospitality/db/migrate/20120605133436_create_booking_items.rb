class CreateBookingItems < ActiveRecord::Migration
  def change
    create_table :booking_items do |t|
      t.integer :booking_id
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.integer :guest_type_id
      t.float :sum

      t.timestamps
    end
  end
end
