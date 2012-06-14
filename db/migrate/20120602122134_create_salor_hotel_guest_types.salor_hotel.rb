class CreateSalorHotelGuestTypes < ActiveRecord::Migration
  def change
    create_table :guest_types do |t|
      t.string :name
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
