class AddPaidToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :paid, :boolean
    add_column :orders, :change_given, :float
  end
end
