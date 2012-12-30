class AddRoleWeightToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role_weight, :integer
  end
end
