class AddLockingDetailsToUser < ActiveRecord::Migration
  def change
    add_column :users, :current_ip, :string
    add_column :users, :last_active_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :last_logout_at, :datetime
  end
end
