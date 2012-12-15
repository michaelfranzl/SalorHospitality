class CopyCategoryIdToTaxItems < ActiveRecord::Migration
  def up
#     Item.all.each do |i|
#       puts "Copying category_id #{ i.category_id } of item #{ i.id } to all its tax_items"
#       i.tax_items.update_all :category_id => i.category_id
#     end
  end

  def down
  end
end
