class MigrateOrderAndItemsToNewTaxSystem < ActiveRecord::Migration
  def up
    Item.all.each do |item|
      item.calculate_totals
    end
    Order.all.each do |order|
      order.calculate_totals
    end
  end

  def down
  end
end
