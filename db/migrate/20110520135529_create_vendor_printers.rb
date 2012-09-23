class CreateVendorPrinters < ActiveRecord::Migration
  def self.up
    create_table :vendor_printers do |t|
      t.string :name
      t.string :path
      t.integer :company_id
      t.boolean :hidden
      t.timestamps
    end

    rename_column :categories, :usage, :vendor_printer_id

    remove_column :companies, :printer_guestroom
    remove_column :companies, :printer_bar
    remove_column :companies, :printer_kitchen
  end

  def self.down
    drop_table :vendor_printers

    rename_column :categories, :vendor_printer_id, :usage

    add_column :companies, :printer_guestroom, :string
    add_column :companies, :printer_bar, :string
    add_column :companies, :printer_kitchen, :string
  end
end
