class CalulateAllTotals < ActiveRecord::Migration
  def up
    puts "Delete all TaxItems"
    TaxItem.delete_all
    
    puts "Calling .calculate_totals for all Items... This may take a while."
    Item.update_all :taxes => {}
    Item.existing.each do |item|
      puts "  Processing Item #{item.id}"
      item.calculate_totals
    end
    
    puts "Calling .calculate_totals for all Orders... This may take a while."
    Item.scope(:existing, lambda { Item.where('hidden = FALSE OR hidden IS NULL') })
    Order.update_all :taxes => "--- {}\n"
    Order.existing.each do |order|
      puts "  Processing Order #{order.id}"
      order.calculate_totals
    end
    
    puts "Calling .calculate_totals for all SurchargeItems... This may take a while."
    SurchargeItem.update_all :taxes => "--- {}\n"
    SurchargeItem.existing.each do |si|
      puts "  Processing SurchargeItem #{si.id}"
      si.calculate_totals
    end
    
    puts "Calling .calculate_totals for all BookingItems... This may take a while."
    BookingItem.update_all :taxes => "--- {}\n"
    BookingItem.existing.each do |bi|
      puts "  Processing BookingItem #{bi.id}"
      bi.calculate_totals
    end
    
    puts "Calling .calculate_totals for all Bookings... This may take a while."
    Booking.update_all :taxes => "--- {}\n"
    Booking.existing.each do |b|
      puts "  Processing Booking #{b.id}"
      b.calculate_totals
    end
  end

  def down
  end
end
