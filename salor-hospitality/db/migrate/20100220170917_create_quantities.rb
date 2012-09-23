class CreateQuantities < ActiveRecord::Migration
  def self.up
    create_table :quantities do |t|
      t.string :name
      t.float :price
      t.integer :article_id

      t.timestamps
    end
  end

  def self.down
    drop_table :quantities
  end
end
