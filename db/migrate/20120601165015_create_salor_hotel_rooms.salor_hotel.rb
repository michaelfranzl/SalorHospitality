# This migration comes from salor_hotel (originally 20120601154758)
class CreateSalorHotelRooms < ActiveRecord::Migration
  def change
    create_table :salor_hotel_rooms do |t|
      t.string :name
      t.text :description
      t.integer :room_type_id
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
