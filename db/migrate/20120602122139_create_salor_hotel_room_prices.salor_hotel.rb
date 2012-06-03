class CreateSalorHotelRoomPrices < ActiveRecord::Migration
  def change
    create_table :room_prices do |t|
      t.integer :room_type_id
      t.integer :guest_type_id
      t.float :base_price
      t.boolean :hidden
      t.string :vendor_id
      t.string :integer
      t.integer :company_id
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
