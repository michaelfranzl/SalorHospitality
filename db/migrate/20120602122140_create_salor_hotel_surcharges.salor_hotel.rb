# This migration comes from salor_hotel (originally 20120601154938)
class CreateSalorHotelSurcharges < ActiveRecord::Migration
  def change
    create_table :salor_hotel_surcharges do |t|
      t.string :name
      t.integer :season_id
      t.integer :guest_type_id
      t.float :amount
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
