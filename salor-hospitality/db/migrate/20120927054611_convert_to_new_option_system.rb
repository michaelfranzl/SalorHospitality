class ConvertToNewOptionSystem < ActiveRecord::Migration
  def up
    Item.all do |i|
      puts "Converting Options of Item #{ i.id }"
      i.options.each do |o|
        OptionItem.create :option_id => o.id, :item_id => i.id, :order_id => i.order_id, :vendor_id => i.vendor_id, :company_id => i.company_id, :price => o.price, :name => o.name, :count => i.count, :sum => o.price * i.count, :hidden => i.hidden, :hidden_by => i.hidden_by
      end
    end
  end
end
