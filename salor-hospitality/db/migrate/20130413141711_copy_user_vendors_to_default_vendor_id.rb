class CopyUserVendorsToDefaultVendorId < ActiveRecord::Migration
  def up
    User.all.each do |u|
      puts "Copying default_vendor_id for user #{ u.id }: #{ u.vendors.existing.first.id }"
      u.default_vendor_id = u.vendors.existing.first.id
    end
  end

  def down
  end
end
