class AddEnableOnscreenKeyboardToUsers < ActiveRecord::Migration
  def change
    add_column :users, :onscreen_keyboard_enabled, :boolean, :default => true
  end
end
