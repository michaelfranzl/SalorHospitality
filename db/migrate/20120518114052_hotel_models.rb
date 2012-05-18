class HotelModels < ActiveRecord::Migration
  def self.up
    create_table :guest_types do |t|
      t.string :name
      t.float  :local_tax_amount
      t.timestamps
    end
    create_table :seasons do |t|
      t.string :name
      t.datetime  :from
      t.datetime  :to
      t.timestamps
    end
    create_table :room_types do |t|
      t.string :name
      t.timestamps
    end
    create_table :rooms do |t|
      t.string :name
      t.text :description
      t.integer :room_type_id
      t.timestamps
    end
    create_table :room_prices do |t|
      t.integer :room_type_id
      t.integer :guest_type_id
      t.float :base_price
      t.timestamps
    end
    create_table :surcharges do |t|
      t.string :name
      t.integer :season_id
      t.integer :guest_type_id
      t.float :surcharge
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



#rails g model guest_types name:string local_tax:float
#rails g model seasons name:string from:datetime to:datetime
#rails g model room_types name:string
#rails g model rooms name:string description:text room_type_id:integer
#rails g model room_prices room_type_id:integer guest_type_id:integer base_price:float
#rails g model surcharges name:string season_id:integer guest_type_id:integer surcharge:float
