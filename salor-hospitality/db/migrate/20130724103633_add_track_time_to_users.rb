class AddTrackTimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :track_time, :boolean
  end
end
