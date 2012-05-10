class ConvertToNewModels < ActiveRecord::Migration
  def up
    if not Company.all.any?
      puts "Converting company"
      company = Company.create :name => 'Restaurant'
      Vendor.update_all :company_id => company.id
      vendor = Vendor.first
      Article.update_all :company_id => company.id, :vendor_id => vendor.id
      Category.update_all :company_id => company.id, :vendor_id => vendor.id
      Article.update_all :company_id => company.id, :vendor_id => vendor.id
      Option.update_all :company_id => company.id, :vendor_id => vendor.id
      Order.update_all :company_id => company.id, :vendor_id => vendor.id, :order_id => nil
      puts "Converting Item"
      Item.update_all :company_id => company.id, :vendor_id => vendor.id, :item_id => nil
      Quantity.update_all :company_id => company.id, :vendor_id => vendor.id
      Role.update_all :company_id => company.id, :vendor_id => vendor.id
      Settlement.update_all :company_id => company.id, :vendor_id => vendor.id
      Table.update_all :company_id => company.id, :vendor_id => vendor.id
      Tax.update_all :company_id => company.id, :vendor_id => vendor.id
      VendorPrinter.update_all :company_id => company.id, :vendor_id => vendor.id
      puts "Converting User"
      User.update_all :company_id => company.id
      User.all.each { |u| u.vendors << vendor; u.save }
    end
  end

  def down
    Company.delete_all
  end
end
