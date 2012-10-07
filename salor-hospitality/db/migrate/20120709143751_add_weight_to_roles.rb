class AddWeightToRoles < ActiveRecord::Migration
  def up
    add_column :roles, :weight, :integer
  end
  def down
    remove_column :roles, :weight
  end
end
