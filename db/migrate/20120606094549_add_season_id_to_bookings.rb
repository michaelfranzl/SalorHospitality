class AddSeasonIdToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :season_id, :integer
  end
end
