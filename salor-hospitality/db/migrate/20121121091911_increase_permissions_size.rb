class IncreasePermissionsSize < ActiveRecord::Migration
  def up
    change_column :roles, :permissions, :string, :limit => 10000, :default => "--- []\n"
  end

  def down
  end
end
