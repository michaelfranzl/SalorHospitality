class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :count
      t.integer :article_id
      t.integer :order_id
      t.boolean :free

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
