class CreateVendorPrinters < ActiveRecord::Migration
  def self.up
    create_table :vendor_printers do |t|
      t.string :name
      t.string :path
      t.integer :company_id
      t.boolean :hidden
      t.timestamps
    end

    remove_column :companies, :printer_guestroom
    remove_column :companies, :printer_bar
    remove_column :companies, :printer_kitchen

    rename_column :categories, :usage, :vendor_printer_id
  end

  def self.down
    drop_table :vendor_printers

    add_column :companies, :printer_guestroom, :string
    add_column :companies, :printer_bar, :string
    add_column :companies, :printer_kitchen, :string

    rename_column :categories, :vendor_printer_id, :usage
  end
end
