class AddDatesToSurchargeItems < ActiveRecord::Migration
  def change
    add_column :surcharge_items, :from_date, :datetime
    add_column :surcharge_items, :to_date, :datetime
  end
end
