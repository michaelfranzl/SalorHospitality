class AddBeepToUsers < ActiveRecord::Migration
  def change
    add_column :users, :audio, :boolean
  end
end
