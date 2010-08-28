class CreateItemOptions < ActiveRecord::Migration
  def self.up
    create_table :item_options do |t|
      t.references :item
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :item_options
  end
end
