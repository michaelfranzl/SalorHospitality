class MoveTechnicianEmailToVendors < ActiveRecord::Migration
  def up
    add_column :vendors, :technician_email, :string
    Vendor.reset_column_information
    Company.all.each do |c|
      c.vendors.update_all :technician_email => c.technician_email
    end
    remove_column :companies, :technician_email
  end

  def down
    remove_column :vendors, :technician_email
    add_column :companies, :technician_email, :string
  end
end
