class PopulateHashIdForVendors < ActiveRecord::Migration
  def up
    Vendor.all.each do |v|
      if v.hash_id.blank?
        puts "Setting hash_id for Vendor #{ v.id }"
        v.set_hash_id
      end
      puts "Vendor #{ v.id } already has hash_id set"
    end
  end

  def down
  end
end
