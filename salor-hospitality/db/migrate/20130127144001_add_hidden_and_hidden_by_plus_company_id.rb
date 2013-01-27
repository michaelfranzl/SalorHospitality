class AddHiddenAndHiddenByPlusCompanyId < ActiveRecord::Migration
  def up
    [Article, BookingItem, Booking, Camera, CashDrawer, CashRegister, Category, Company, CostCenter, Coupon, Customer, Discount, Email, GuestType, History, Image, Ingredient, Item, OptionItem, Option, Order, Page, Partial, PaymentMethodItem, PaymentMethod, Presentation, Quantity, Receipt, Reservation, Role, RoomPrice, RoomType, Room, Season, Settlement, StatisticCategory, Stock, SurchargeItem, Surcharge, Table, TaxAmount, TaxItem, Tax, User, VendorPrinter, Vendor].each do |model|
      
      # Coupon, Discount, Reservation
      model.reset_column_information

      if not model.column_names.include? 'hidden' then
        puts "Adding :hidden column :boolean to #{model}"
        add_column model.table_name.to_sym, :hidden, :boolean
      end
      
      if not model.column_names.include? 'hidden_by' then
        puts "Adding :hidden_by column :integer to #{model}"
        add_column model.table_name.to_sym, :hidden_by, :integer
      end
      
      if not model.column_names.include? 'hidden_at' then
        puts "Adding :hidden_at column :datetime to #{model}"
        add_column model.table_name.to_sym, :hidden_at, :datetime
      end
    end
    
    # add company_id and vendor_id to all models except Company, Vendor, User
    [Article, BookingItem, Booking, Camera, CashDrawer, CashRegister, Category, CostCenter, Coupon, Customer, Discount, Email, GuestType, History, Image, Ingredient, Item, OptionItem, Option, Order, Page, Partial, PaymentMethodItem, PaymentMethod, Presentation, Quantity, Receipt, Reservation, Role, RoomPrice, RoomType, Room, Season, Settlement, StatisticCategory, Stock, SurchargeItem, Surcharge, Table, TaxAmount, TaxItem, Tax, VendorPrinter].each do |model|
      
      # Coupon, Discount, Reservation
      model.reset_column_information

      if not model.column_names.include? 'vendor_id' then
        puts "Adding :vendor_id column :integer to #{model}"
        add_column model.table_name.to_sym, :vendor_id, :integer
      end
      
      if not model.column_names.include? 'company_id' then
        puts "Adding :company_id column :integer to #{model}"
        add_column model.table_name.to_sym, :company_id, :integer
      end
    end
    
  end

  def down
  end
end
