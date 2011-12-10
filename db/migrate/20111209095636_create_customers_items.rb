class CreateCustomersItems < ActiveRecord::Migration
  def self.up
    create_table :customers_items, :id => false do |t|
      t.references :customer
      t.references :item
    end
    remove_column :items, :customer_id
  end

  def self.down
    drop_table :customers_items
    add_column :items, :customer_id, :integer
  end
end
