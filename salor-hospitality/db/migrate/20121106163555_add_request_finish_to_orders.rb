class AddRequestFinishToOrders < ActiveRecord::Migration
  def change
    add_column :tables, :request_finish, :boolean
    add_column :tables, :request_waiter, :boolean
  end
end
