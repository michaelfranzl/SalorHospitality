class AddHiddenToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :hidden, :boolean

  end
end
