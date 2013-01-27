class AddHiddenAndHiddenBy < ActiveRecord::Migration
  def up
    [Article, BookingItem, Booking, Camera, CashDrawer, CashRegister, Category, Company, CostCenter, Customer, Email, GuestType, History, Image, Ingredient, Item, OptionItem, Option, Order, Page, Partial, PaymentMethodItem, PaymentMethod, Presentation, Quantity, Receipt, Role, RoomPrice, RoomType, Room, Season, Settlement, StatisticCategory, Stock, SurchargeItem, Surcharge, Table, TaxAmount, TaxItem, Tax, User, VendorPrinter, Vendor].each do |model|
      
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
    
  end

  def down
  end
end
