class ConvertToNewModels < ActiveRecord::Migration
  def up
    Company.reset_column_information
    if User.all.any?
      if not Company.all.any?
        company = Company.new :name => 'Company'
        company.save(:validate => false)
        if Vendor.all.any?
          Vendor.update_all :company_id => company.id
          vendor = Vendor.first
        else
          vendor = Vendor.create :company_id => company.id, :name => 'Restaurant'
        end
        
        if vendor
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
    end
  end

  def down
    Company.delete_all
  end
end
