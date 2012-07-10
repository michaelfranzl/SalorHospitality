class AddWeightToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :weight, :integer
  end
end
