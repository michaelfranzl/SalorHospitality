class CopySettlementIdToNr < ActiveRecord::Migration
  def up
    Settlement.connection.execute('UPDATE settlements SET nr = id')
    Vendor.all.each do |v|
      nr = v.settlements.count
      v.update_attribute :largest_settlement_number, nr
    end
  end

  def down
  end
end
