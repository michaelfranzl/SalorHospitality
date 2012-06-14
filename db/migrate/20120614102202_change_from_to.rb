class ChangeFromTo < ActiveRecord::Migration
  def up
    rename_column :seasons, :from, :from_date
    rename_column :seasons, :to, :to_date
    rename_column :bookings, :from, :from_date
    rename_column :bookings, :to, :to_date
  end

  def down
    rename_column :seasons, :from_date, :from
    rename_column :seasons, :to_date, :to
    rename_column :bookings, :from_date, :from
    rename_column :bookings, :to_date, :to
  end
end
