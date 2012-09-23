class AddReceiptBlurbsToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :receipt_header_blurb, :text
    add_column :vendors, :receipt_footer_blurb, :text
    add_column :vendors, :invoice_header_blurb, :text
    add_column :vendors, :invoice_footer_blurb, :text
    remove_column :vendors, :invoice_subtitle
    remove_column :vendors, :address
    remove_column :vendors, :revenue_service_tax_number
    remove_column :vendors, :invoice_slogan1
    remove_column :vendors, :invoice_slogan2
    remove_column :vendors, :internet_address
    remove_column :vendors, :email
    remove_column :vendors, :bank_account1
    remove_column :vendors, :bank_account2
  end
end
