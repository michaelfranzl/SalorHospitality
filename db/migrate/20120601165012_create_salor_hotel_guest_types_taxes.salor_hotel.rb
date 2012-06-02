# This migration comes from salor_hotel (originally 20120601154543)
class CreateSalorHotelGuestTypesTaxes < ActiveRecord::Migration
  def change
    create_table :salor_hotel_guest_types_taxes, :id => false do |t|
      t.integer :guest_type_id
      t.integer :tax_id
    end
  end
end
