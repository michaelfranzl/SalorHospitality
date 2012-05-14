class AddConfigToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :invoice_subtitle, :string, :default => ''
    add_column :companies, :address, :string, :default => ''
    add_column :companies, :revenue_service_tax_number, :string, :default => ''
    add_column :companies, :invoice_slogan1, :string, :default => ''
    add_column :companies, :invoice_slogan2, :string, :default => ''
    add_column :companies, :internet_address, :string, :default => 'www.billgastro.com'
    add_column :companies, :email, :string, :default => 'office@billgastro.com'
    add_column :companies, :printer_kitchen, :string, :default => '/dev/usblp0'
    add_column :companies, :printer_bar, :string, :default => '/dev/usblp0'
    add_column :companies, :printer_guestroom, :string, :default => '/dev/usblp0'
    add_column :companies, :automatic_printing, :boolean, :default => false
    add_column :companies, :largest_order_number, :integer, :default => 0
    add_column :companies, :unused_order_numbers, :string, :default => []
  end

  def self.down
    remove_column :companies, :unused_order_numbers
    remove_column :companies, :largest_order_number
    remove_column :companies, :automatic_printing
    remove_column :companies, :printer_guestroom
    remove_column :companies, :printer_bar
    remove_column :companies, :printer_kitchen
    remove_column :companies, :email
    remove_column :companies, :internet_address
    remove_column :companies, :invoice_slogan1
    remove_column :companies, :invoice_slogan2
    remove_column :companies, :revenue_service_tax_number
    remove_column :companies, :address
    remove_column :companies, :invoice_subtitle
  end
end
