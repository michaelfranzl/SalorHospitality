class MigrateOrderAndItemsToNewTaxSystem < ActiveRecord::Migration
  def up
    puts "Migrating Items to new tax system... This may take a while."
    Item.update_all :taxes => nil
    Item.all.each do |item|
      puts "  Migrating item #{item.id}"
      item.calculate_totals
    end
    puts "Migrating Orders to new tax system... This may take a while."
    Item.scope(:existing, lambda { Item.where('hidden = FALSE OR hidden IS NULL') })
    Order.update_all :taxes => nil
    Order.all.each do |order|
      puts "  Migrating order #{order.id}"
      order.calculate_totals
    end
  end

  def down
  end
end
