class AddLoginDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hourly_rate, :float
    add_column :users, :maximum_shift_duration, :integer
  end
end
