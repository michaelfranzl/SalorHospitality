class CalculateSettlementSume < ActiveRecord::Migration
  def up
    Settlement.all.each do |s|
      puts "Updating Settlement #{s.id} total..."
      s.calculate_totals
    end
  end

  def down
  end
end
