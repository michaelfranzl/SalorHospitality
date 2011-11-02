class CreatePartials < ActiveRecord::Migration
  def self.up
    create_table :partials do |t|
      t.integer :x
      t.integer :y
      t.text :code
      t.text :template
      t.text :blurb
      t.boolean :active, :default => true
      t.boolean :hidden

      t.timestamps
    end
  end

  def self.down
    drop_table :partials
  end
end
