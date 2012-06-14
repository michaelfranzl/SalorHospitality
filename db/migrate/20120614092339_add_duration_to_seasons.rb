class AddDurationToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :duration, :integer
  end
end
