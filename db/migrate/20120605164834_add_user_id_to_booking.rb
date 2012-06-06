class AddUserIdToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :user_id, :integer
  end
end
