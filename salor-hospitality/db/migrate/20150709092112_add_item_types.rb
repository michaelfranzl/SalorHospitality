class AddItemTypes < ActiveRecord::Migration
  def up
    Article.reset_column_information
    Item.reset_column_information
    begin
    
    Vendor.where(:hidden => nil).each do |v|
      # This will only be effective on an already seeded database...
      puts "-- Creating ItemTypes for Vendor #{ v.id }..."
      unless v.item_types.any?
        # ... and only when no ItemTypes exist yet
        behaviors = ["normal", "gift_card", "coupon"]
        behaviors.each do |b|
          it = ItemType.new
          it.vendor = v
          it.company = v.company
          it.behavior = b
          it.name = I18n.t "item_type_names.#{ b }", :locale => v.get_region.to_s[0..1]
          res = it.save
          puts "Created ItemType #{ it.id } with behavior #{ b }"
          if res == true and b == "normal"
            puts "Setting all Articles to Item Type 'normal' with ItemType ID #{ it.id }"
            v.articles.existing.update_all :item_type_id => it.id
          end

        end
      end
    end
    rescue Exception => e
      puts "Exception #{ e } during creation of ItemTypes."
    end
  end

  def down
  end
end
