class CopyNamesToIdentifiersForVendors < ActiveRecord::Migration
  def up
    i = 0
    Vendor.existing.all.each do |v|
      puts "Setting Identifier #{ v.name }#{ i } for Vendor ID #{ v.id }"
      v.update_attribute :identifier, "#{ v.name }#{ i }"
      i += 1
   end
  end

  def down
  end
end
