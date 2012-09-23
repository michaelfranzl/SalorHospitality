class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.string :name
      t.float :amount, :default => 0.0
      t.integer :ctype
      t.string :sku
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :more_than_1_allowed, :default => true
      t.integer :article_id
      t.boolean :time_based, :default => false
      t.integer :company_id
      t.timestamps
    end
    add_index(:coupons, [:company_id], :name => :coupons_company_id_index)
    create_table :coupons_orders, :id => false do |t|
      t.references :coupon
      t.references :order
    end
    add_index(:coupons_orders, [:coupon_id], :name => :coupons_orders_coupon_id_index)
    add_index(:coupons_orders, [:order_id], :name => :coupons_orders_order_id_index)
  end

  def self.down
    drop_table :coupons
    drop_table :coupons_orders
  end
end
