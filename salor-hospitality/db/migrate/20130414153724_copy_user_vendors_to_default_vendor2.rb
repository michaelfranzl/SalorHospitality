class CopyUserVendorsToDefaultVendor2 < ActiveRecord::Migration
  def up
    User.all.each do |u|
      vendor = u.vendors.first
      if vendor
        puts "Copying default_vendor_id for user #{ u.id }: #{ vendor.id }"
        u.update_attribute :default_vendor_id, vendor.id
      else
        puts "No vendors for user #{ u.id }"
      end
    end
  end

  def down
  end
end
