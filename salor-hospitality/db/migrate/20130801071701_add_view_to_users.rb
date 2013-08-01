class AddViewToUsers < ActiveRecord::Migration
  def change
    add_column :users, :layout, :string, :default => 'auto'
  end
end
