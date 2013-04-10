class AddTimestampsToSurchargeItems < ActiveRecord::Migration
  def change
    add_column :surcharge_items, :created_at, :datetime
    add_column :surcharge_items, :updated_at, :datetime
  end
end
