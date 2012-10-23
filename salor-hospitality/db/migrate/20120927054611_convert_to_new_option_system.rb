class ConvertToNewOptionSystem < ActiveRecord::Migration
  def up
    OptionItem.delete_all

    result = ActiveRecord::Base.connection.execute("SELECT item_id, option_id from items_options")
    
    result.to_a.each do |item_id, option_id|
      puts "Creating OptionItem for item_id #{item_id} and option_id #{option_id}"
      i = Item.find_by_id(item_id)
      o = Option.find_by_id(option_id)
      OptionItem.create(:option_id => o.id, :item_id => i.id, :order_id => i.order_id, :vendor_id => i.vendor_id, :company_id => i.company_id, :price => o.price, :name => o.name, :count => i.count, :sum => o.price * i.count, :hidden => i.hidden, :hidden_by => i.hidden_by) if i and o
    end
  end
  
  def down
  end
end
