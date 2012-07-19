class AddSeasonIdToRoomPrices < ActiveRecord::Migration
  def change
    add_column :room_prices, :season_id, :integer
  end
end
