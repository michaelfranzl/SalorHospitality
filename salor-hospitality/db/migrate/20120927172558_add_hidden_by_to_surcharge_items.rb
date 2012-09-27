class AddHiddenByToSurchargeItems < ActiveRecord::Migration
  def change
    add_column :surcharge_items, :hidden_by, :integer
  end
end
