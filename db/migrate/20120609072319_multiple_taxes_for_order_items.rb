class MultipleTaxesForOrderItems < ActiveRecord::Migration
  def up
    remove_column :booking_items, :tax_sum
    remove_column :bookings, :tax_sum
    remove_column :categories, :tax_id
    add_column :orders, :taxes, :string, :default => "--- {}\n"
    add_column :items, :taxes, :string, :default => "--- {}\n"
  end

  def down
    remove_column :orders, :taxes
    remove_column :items, :taxes
  end
end
