class MultipleTaxesForOrderItems < ActiveRecord::Migration
  def up
    remove_column :booking_items, :tax_sum
    remove_column :bookings, :tax_sum
    remove_column :categories, :tax_id
    add_column :orders, :taxes, :string, :default => "--- {}\n"
    add_column :items, :taxes, :string, :default => "--- {}\n"
    create_table :articles_taxes, :id => false do |t|
      t.integer :tax_id
      t.integer :article_id
    end
  end

  def down
    remove_column :orders, :taxes
    remove_column :items, :taxes
    drop_table :articles_taxes
  end
end
