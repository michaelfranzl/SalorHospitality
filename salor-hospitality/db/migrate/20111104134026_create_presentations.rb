class CreatePresentations < ActiveRecord::Migration
  def self.up
    create_table :presentations do |t|
      t.string :name
      t.string :description
      t.text :markup
      t.text :code
      t.string :model
      t.boolean :active, :default => true
      t.boolean :hidden

      t.timestamps
    end
  end

  def self.down
    drop_table :presentations
  end
end
