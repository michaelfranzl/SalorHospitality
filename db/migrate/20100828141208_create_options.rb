class CreateOptions < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.references :category
      t.references :option
      t.string :name
      t.float :price
      t.timestamps
    end
  end

  def self.down
    drop_table :options
  end
end
