class CopySettlementIdToItems < ActiveRecord::Migration
  def up
    Order.all.each do |o|
      puts "Updating Iems and TaxItems of order #{o.id} with settlement_id #{o.settlement_id}"
      Item.where(:order_id => o.id).update_all :settlement_id => o.settlement_id
      TaxItem.where(:order_id => o.id).update_all :settlement_id => o.settlement_id
    end
  end

  def down
  end
end
