class AddPrintedInterimToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :printed_interim, :boolean
  end
end
