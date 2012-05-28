class HotelModels < ActiveRecord::Migration
  def self.up
    create_table :guest_types do |t|
      t.string :name
      t.float  :local_tax_amount
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :active, :default => true
      t.timestamps
    end
    create_table :seasons do |t|
      t.string :name
      t.datetime  :from
      t.datetime  :to
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :active, :default => true
      t.timestamps
    end
    create_table :room_types do |t|
      t.string :name
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :active, :default => true
      t.timestamps
    end
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
    create_table :room_prices do |t|
      t.integer :room_type_id
      t.integer :guest_type_id
      t.float :base_price
      t.boolean :hidden
      t.integer :vendor_id
      t.integer :company_id
      t.boolean :active, :default => true
      t.timestamps
    end
    create_table :surcharges do |t|
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
  def self.down
    drop_table :guest_types
    drop_table :seasons
    drop_table :room_types
    drop_table :rooms
    drop_table :room_prices
    drop_table :surcharges
  end
end
