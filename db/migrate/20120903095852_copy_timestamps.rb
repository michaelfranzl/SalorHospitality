class CopyTimestamps < ActiveRecord::Migration
  def up
    Order.where(:paid => nil).update_all :paid => false
    Order.where(:finished => true).update_all :paid => true

    Order.where(:finished => true, :finished_at => nil).each do |o|
      # Todo: This doesnt seem to be working. Have to run manually in console
      puts "Updating finished_at for Order #{ o.id }"
      o.finished_at = o.created_at
      o.save
    end
    Booking.where(:finished => true, :finished_at => nil).each do |b|
      puts "Updating finished_at for Booking #{ b.id }"
      b.finished_at = b.created_at
      b.save
    end
    
    Order.all.each do |o|
      puts "Copying paid_at for Order #{ o.id }"
      o.paid_at = o.finished_at
      o.save
    end
    Booking.all.each do |b|
      # Todo: This doesnt seem to be working. Have to run manually in console
      puts "Copying paid_at for Booking #{ b.id }"
      b.paid_at = b.finished_at
      b.save
    end
  end

  def down
  end
end
