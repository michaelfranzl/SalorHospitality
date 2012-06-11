class CreateSalorHotelRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
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
