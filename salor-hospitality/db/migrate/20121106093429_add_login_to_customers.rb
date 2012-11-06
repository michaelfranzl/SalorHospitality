class AddLoginToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :password, :string
    add_column :customers, :login, :string
    add_column :customers, :role_id, :integer
    add_column :customers, :language, :string
    add_column :customers, :active, :boolean, :default => true
    add_column :customers, :onscreen_keyboard_enabled, :boolean, :default => false
    add_column :customers, :current_ip, :string
    add_column :customers, :last_active_at, :datetime
    add_column :customers, :last_login_at, :datetime
    add_column :customers, :last_logout_at, :datetime
  end
end
