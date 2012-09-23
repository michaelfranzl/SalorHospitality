class AddReceiptLogosToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :rlogo_header, :text
    add_column :vendors, :rlogo_footer, :text
  end
end
