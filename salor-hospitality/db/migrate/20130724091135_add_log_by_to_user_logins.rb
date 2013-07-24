class AddLogByToUserLogins < ActiveRecord::Migration
  def change
    add_column :user_logins, :log_by_user_id, :integer
  end
end
