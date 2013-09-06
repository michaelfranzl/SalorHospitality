class DefaultsForUserLogins < ActiveRecord::Migration
  def up
    change_column_default :users, :maximum_shift_duration, 9999
    User.where(:maximum_shift_duration => nil).update_all :maximum_shift_duration => 9999
  end

  def down
  end
end
