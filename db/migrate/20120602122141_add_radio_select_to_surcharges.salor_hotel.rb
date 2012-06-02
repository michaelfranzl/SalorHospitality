# This migration comes from salor_hotel (originally 20120602121539)
class AddRadioSelectToSurcharges < ActiveRecord::Migration
  def change
    add_column :salor_hotel_surcharges, :radio_select, :boolean
  end
end
