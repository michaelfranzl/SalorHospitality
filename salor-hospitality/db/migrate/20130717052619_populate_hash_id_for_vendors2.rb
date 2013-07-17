class PopulateHashIdForVendors2 < ActiveRecord::Migration
  def up
    Vendor.all.each do |v|
      match = /[a-zA-Z0-9_-]*/.match(v.identifier)
      next unless match
      matched = match[0]
      if matched != v.identifier
        puts "Identifier contains something else than [a-zA-Z0-9_-]. Sorry, I have to reset the identifer."
        Vendor.connection.execute("UPDATE vendors SET identifier = 'vendor#{ v.id }' WHERE id=#{ v.id }")
      end
    end
    
    Vendor.all.each do |v|
      v.reload
      puts "Saving Vendor #{ v.id } to set hash_id if not present."
      v.save
    end
  end

  def down
  end
end
