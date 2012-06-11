class CreateSalorHotelGuestTypesTaxes < ActiveRecord::Migration
  def change
    create_table :guest_types_taxes, :id => false do |t|
      t.integer :guest_type_id
      t.integer :tax_id
    end
  end
end
