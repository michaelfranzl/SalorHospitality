class CreateIngredients < ActiveRecord::Migration
  def self.up
    create_table :ingredients do |t|
      t.float :amount
      t.integer :article_id
      t.integer :stock_id

      t.timestamps
    end
  end

  def self.down
    drop_table :ingredients
  end
end
