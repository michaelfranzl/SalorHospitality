class AddPrintedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :printed, :boolean
  end
end
