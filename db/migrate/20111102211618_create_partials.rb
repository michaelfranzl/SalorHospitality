class CreatePartials < ActiveRecord::Migration
  def self.up
    create_table :partials do |t|
      t.integer :left
      t.integer :top
      t.integer :presentation_id, :default => 1
      t.text :blurb
      t.boolean :active, :default => true
      t.boolean :hidden
      t.integer :model_id

      t.timestamps
    end
  end

  def self.down
    drop_table :partials
  end
end
