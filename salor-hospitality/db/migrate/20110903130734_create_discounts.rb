class CreateDiscounts < ActiveRecord::Migration
  def self.up
    create_table :discounts do |t|
      t.string :name
      t.float :amount
      t.integer :dtype
      t.integer :category_id
      t.integer :company_id
      t.integer :article_id
      t.boolean :time_based
      t.integer :start_time
      t.integer :end_time

      t.timestamps
    end
    add_index(:discounts, [:company_id], :name => :index_discounts_company_id)
    add_index(:discounts, [:article_id], :name => :index_discounts_article_id)
    add_index(:discounts, [:category_id], :name => :index_discounts_category_id)
    create_table :discounts_orders, :id => false do |t|
      t.references :order
      t.references :discount
    end
    add_index(:discounts_orders, [:order_id], :name => :index_discounts_orders_order_id)
  end

  def self.down
    drop_table :discounts
    drop_table :discounts_orders
  end
end
