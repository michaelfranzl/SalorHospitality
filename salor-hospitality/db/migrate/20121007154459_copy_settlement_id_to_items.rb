class CopySettlementIdToItems < ActiveRecord::Migration
  def up
#     Order.all.each do |o|
#       puts "Updating Items and TaxItems with settlement_id of order #{ o.id }"
#       Item.where(:order_id => o.id).update_all :settlement_id => o.settlement_id
#       TaxItem.where(:order_id => o.id).update_all :settlement_id => o.settlement_id
#     end
  end

  def down
  end
end
