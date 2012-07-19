class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.datetime :from
      t.datetime :to
      t.integer :customer_id
      t.float :sum
      t.boolean :hidden
      t.boolean :paid, :default => false
      t.text :note
      t.integer :vendor_id
      t.integer :company_id

      t.timestamps
    end
  end
end
