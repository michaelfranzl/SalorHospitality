# This migration comes from salor_hotel (originally 20120601154706)
class CreateSalorHotelRoomTypes < ActiveRecord::Migration
  def change
    create_table :salor_hotel_room_types do |t|
      t.string :name
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
