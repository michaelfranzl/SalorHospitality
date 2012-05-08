class AddToItems2 < ActiveRecord::Migration
  def change
    add_column :items, :refunded, :boolean
    add_column :items, :refund_sum, :float
    add_column :items, :refunded_by, :integer
    rename_column :orders, :storno_sum, :refund_sum
  end
end

