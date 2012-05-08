class AddHiddenByToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :hidden_by, :integer
  end
end
