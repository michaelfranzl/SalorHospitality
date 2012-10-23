class CopySettlementIdToItems < ActiveRecord::Migration
  def up
    puts "Updating Items and TaxItems with settlement_id of order"
    Order.all.each do |o|
      Item.where(:order_id => o.id, :settlement_id => nil).update_all :settlement_id => o.settlement_id
      TaxItem.where(:order_id => o.id, :settlement_id => nil).update_all :settlement_id => o.settlement_id
    end
  end

  def down
  end
end
