class AddVisibleAndDefaultToSurcharges < ActiveRecord::Migration
  def change
    add_column :surcharges, :visible, :boolean, :default => true
    add_column :surcharges, :selected, :boolean, :default => false
  end
end
