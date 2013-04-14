class CopyUserVendorsToDefaultVendorId < ActiveRecord::Migration
  def up
    User.all.each do |u|
      puts "Copying default_vendor_id for user #{ u.id }: #{ u.vendors.existing.first.id }"
      vendor = u.vendors.first
      if vendor
        u.default_vendor_id = vendor.id
        u.save
      end
    end
  end

  def down
  end
end
