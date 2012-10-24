class AddCostCenterIdToTaxItems < ActiveRecord::Migration
  def up
    add_column :tax_items, :cost_center_id, :integer
    add_column :payment_method_items, :cost_center_id, :integer
    Order.all.each do |o|
      o.items.update_all :cost_center_id => o.cost_center_id
      o.payment_method_items.update_all :cost_center_id => o.cost_center_id
      o.tax_items.update_all :cost_center_id => o.cost_center_id
    end
  end
  def down
    remove_column :tax_items, :cost_center_id
    remove_column :payment_method_items, :cost_center_id
  end
end
