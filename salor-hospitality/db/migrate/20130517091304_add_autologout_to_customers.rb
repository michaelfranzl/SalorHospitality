class AddAutologoutToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :logged_in, :boolean
  end
end
