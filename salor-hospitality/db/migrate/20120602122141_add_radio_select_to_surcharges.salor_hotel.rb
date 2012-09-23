class AddRadioSelectToSurcharges < ActiveRecord::Migration
  def change
    add_column :surcharges, :radio_select, :boolean
  end
end
