class AddConfirmationUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_user, :boolean
  end
end
