class AddIsMasterToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :is_master, :boolean
  end
end
