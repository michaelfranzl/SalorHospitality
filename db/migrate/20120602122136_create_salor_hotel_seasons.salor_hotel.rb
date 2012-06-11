class CreateSalorHotelSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string :name
      t.datetime :from
      t.datetime :to
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
