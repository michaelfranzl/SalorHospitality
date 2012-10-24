class AddRefundedToTaxItems < ActiveRecord::Migration
  def up
    add_column :tax_items, :refunded, :boolean
    Item.where('refunded IS NOT NULL').each do |i|
      puts "Setting refunded to true for all TaxItems of item #{i.id}"
      i.tax_items.update_all :refunded => true
    end
  end
  def down
    remove_column :tax_items, :refunded
  end
end
