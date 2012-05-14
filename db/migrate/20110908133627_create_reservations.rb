class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.datetime :res_datetime
      t.integer :party_size
      t.string :name
      t.string :email
      t.string :phone
      t.references :table
      t.references :company
      t.text :diet_restrictions
      t.string :occasion
      t.string :honor
      t.text :allergies
      t.text :other
      t.text :menu_selection
      t.string :fb_user_id
      t.timestamps
      t.string :fb_res_id
    end
  end

  def self.down
    drop_table :reservations
  end
end
