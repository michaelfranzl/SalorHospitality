class AddEnableTechnicianEmailToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :enable_technician_emails, :boolean, :default => false
  end
end
