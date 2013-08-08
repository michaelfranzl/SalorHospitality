# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Report
  def self.dump_all(from, to, device)
    tfrom = from.strftime("%Y%m%d")
    tto = to.strftime("%Y%m%d")

    items = $Vendor.items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityItems#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;count;article_id;order_id;created_at;updated_at;quantity_id;price;max_count;min_count;user_id;hidden;hidden_at;hidden_by;category_id;tax_sum;refunded;refund_sum;refunded_by;settlement_id;cost_center_id;taxes"
      f.write("#{attributes}\n")
      f.write Report.to_csv(items, Item, attributes)
    end
    
    booking_items = $Vendor.booking_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityBookingItems#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;booking_id;guest_type_id;sum;created_at;updated_at;count;base_price;refund_sum;taxes;from_date;to_date;season_id;duration;booking_item_id;ui_parent_id;ui_id;unit_sum;room_id;date_locked;tax_sum;hidden;hidden_at;hidden_by"
      f.write("#{attributes}\n")
      f.write Report.to_csv(booking_items, BookingItem, attributes)
    end
    
    surcharge_items = $Vendor.surcharge_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalitySurchargeItems#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;surcharge_id;booking_item_id;amount;season_id;guest_type_id;taxes;sum;duration;count;from_date;to_date;tax_sum;booking_id;hidden;hidden_at;hidden_by;created_at;updated_at"
      f.write("#{attributes}\n")
      f.write Report.to_csv(surcharge_items, SurchargeItem, attributes)
    end
    
    bookings = $Vendor.bookings.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityBookings#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;from_date;to_date;customer_id;sum;paid;note;created_at;updated_at;room_id;finished;user_id;refund_sum;nr;change_given;duration;taxes;booking_item_sum;finished_at;paid_at;tax_sum;hidden;hidden_at;hidden_by"
      f.write("#{attributes}\n")
      f.write Report.to_csv(bookings, Booking, attributes)
    end
    
    orders = $Vendor.orders.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityOrders#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;finished;table_id;user_id;settlement_id;created_at;updated_at;sum;cost_center_id;printed_from;nr;tax_id;refund_sum;note;customer_id;hidden;hidden_at;hidden_by;printed;paid;booking_id;taxes;finished_at;paid_at;reactivated;reactivated_by;reactivated_at"
      f.write("#{attributes}\n")
      f.write Report.to_csv(orders, Order, attributes)
    end
    
    taxes = $Vendor.taxes
    File.open("#{device}/SalorHospitalityTaxes#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;percent;name;created_at;updated_at;letter;hidden;hidden_by;hidden_at"
      f.write("#{attributes}\n")
      f.write Report.to_csv(taxes, Tax, attributes)
    end
    
    option_items = $Vendor.option_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityOptionItem#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;option_id;item_id;order_id;price;name;count;sum;created_at;updated_at;no_ticket;separate_ticket;hidden;hidden_by;hidden_at"
      f.write("#{attributes}\n")
      f.write Report.to_csv(option_items, OptionItem, attributes)
    end
    
    tax_items = $Vendor.tax_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityTaxItem#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;tax_id;item_id;booking_item_id;order_id;booking_id;settlement_id;gro;net;tax;created_at;updated_at;letter;surcharge_item_id;name;percent;hidden;hidden_by;hidden_at;refunded;cost_center_id;category_id"
      f.write("#{attributes}\n")
      f.write Report.to_csv(tax_items, TaxItem, attributes)
    end
    
    pmis = $Vendor.payment_method_items.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityPaymentMethodItems#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;payment_method_id;order_id;amount;created_at;updated_at;booking_id;refunded;cash;refund_item_id;settlement_id;cost_center_id;change;hidden;hidden_by;hidden_at"
      f.write("#{attributes}\n")
      f.write Report.to_csv(pmis, PaymentMethodItem, attributes)
    end
    
    settlements = $Vendor.settlements.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalitySettlements#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;nr;revenue;user_id;created_at;updated_at;finished;initial_cash;sum;hidden;hidden_by;hidden_at"
      f.write("#{attributes}\n")
      f.write Report.to_csv(settlements, Settlement, attributes)
    end
    
    options = $Vendor.options
    File.open("#{device}/SalorHospitalityOptions#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;name;price;created_at;updated_at;hidden;hidden_by;hidden_at;active;separate_ticket;no_ticket"
      f.write("#{attributes}\n")
      f.write Report.to_csv(options, Option, attributes)
    end
    
    articles = $Vendor.articles
    File.open("#{device}/SalorHospitalityArticles#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;name;description;category_id;price;active;created_at;updated_at;hidden;hidden_at;hidden_by"
      f.write("#{attributes}\n")
      f.write Report.to_csv(articles, Article, attributes)
    end
    
    quantities = $Vendor.quantities
    File.open("#{device}/SalorHospitalityQuantities#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;prefix;postfix;price;article_id;created_at;updated_at;active;hidden;hidden_by;hidden_at;category_id;article_name"
      f.write("#{attributes}\n")
      f.write Report.to_csv(quantities, Quantity, attributes)
    end
    
    users = $Vendor.users
    File.open("#{device}/SalorHospitalityUsers#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;login;title;created_at;updated_at;role_id;active;hidden;hidden_at;hidden_by;last_active_at;last_login_at;last_logout_at;email"
      f.write("#{attributes}\n")
      f.write Report.to_csv(users, User, attributes)
    end
    
    cost_centers = $Vendor.cost_centers
    File.open("#{device}/SalorHospitalityCostCenters#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;name;description;created_at;updated_at;hidden;hidden_by;hidden_at;no_payment_methods"
      f.write("#{attributes}\n")
      f.write Report.to_csv(cost_centers, CostCenter, attributes)
    end
    
    
    payment_methods = $Vendor.payment_methods
    File.open("#{device}/SalorHospitalityPaymentMethods#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;name;created_at;updated_at;hidden;hidden_by;hidden_at;cash;change"
      f.write("#{attributes}\n")
      f.write Report.to_csv(payment_methods, PaymentMethod, attributes)
    end
   
    
    histories = $Vendor.histories.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityHistories#{tfrom}-#{tto}.csv","w") do |f|
      attributes = "id;url;user_id;action_taken;model_type;model_id;ip;changes_made;params;created_at;updated_at"
      f.write("#{attributes}\n")
      f.write Report.to_csv(histories, History, attributes)
    end
    
    receipts = $Vendor.receipts.where(:created_at => from..to)
    File.open("#{device}/SalorHospitalityReceipts#{tfrom}-#{tto}.txt","w:ASCII-8BIT") do |f|
      receipts.each do |r|
        string = "\n\nReceipt id:%i, user_id:%i, vendor_printer_id:%i, order_id:%i, order_nr:%i, created_at:%s\n\n" % [r.id, r.user_id.to_i, r.vendor_printer_id.to_i, r.order_id.to_i, r.order_nr.to_i, r.created_at]
        f.write string
        f.write r.content.gsub("\e@\e!8\n", "").gsub("\x1DV\x00\ep\x00\x99\x99\f".force_encoding('ASCII-8BIT'), "")
      end
    end
    
    # Missing models for report, but not critical: Room, RoomType, RoomPrice, GuestType, Surcharge, Season
  end
  
  
  def self.to_csv(objects, klass, attributes)
    attrs = attributes.split(";")
    formatstring = ""
    attrs.each do |a|
      #puts "ATTR #{ klass.to_s}: #{ a }"
      cls = klass.columns_hash[a].type if klass.columns_hash[a]
      case cls
      when :integer
        formatstring += "%i;"
      when :datetime, :string, :boolean, :text
        formatstring += "%s;"
      when :float
        formatstring += "%.2f;"
      else
        formatstring += "%s;"
      end
    end
    lines = []
    objects.each do |item|
      values = []
      attrs.size.times do |j|
        val = attrs[j].split('.').inject(item) do |klass, method|
          klass.send(method) unless klass.nil?
        end
        val = 0 if val.nil?
        values << val
      end
      lines << sprintf(formatstring, *values)
    end
    
    return lines.join("\n")
  end
 
end
