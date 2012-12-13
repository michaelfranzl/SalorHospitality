class SetCostCenterForAllRefundPmis < ActiveRecord::Migration
  def up
    PaymentMethodItem.where(:refunded => true).each do |pmi|
      puts "Updating refund PaymentMethodItem #{pmi.id} with cost_center_id from parent Item"
      pmi.update_attribute :cost_center_id, pmi.order.cost_center_id
    end
  end

  def down
  end
end
