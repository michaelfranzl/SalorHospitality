# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if User.any?
  puts "Database is already seeded. Not running seed script again."
  Process.exit
end

category_labels = ['Starters','Main Dish','Desserts','Rose Wine','Red Wine','Digestiv'] #,'Alcohol','Coffee','Tea','Tobacco','Beer','Aperitiv','White Wine','Side Dish','Divers']
category_icons = ['starter','maindish','dessert','rosewineglass','redwineglass','digestif'] #,'nonalcoholics','coffee','teapot','cigarette','beer','aperitif','whitewineglass','sidedish','blank']

company_count = 0

if ENV['SEED_MODE'] == 'full'
  puts "SEED_MODE is 'full'"
  countries = ['us','at','fr','es','pl','hu','ru','it','tr','cn','el','hk','tw']
  languages = ['en','gn','fr','es','pl','hu','ru','it','tr','cn','el','hk','tw']
  company_count = 2
else
  puts "SEED_MODE is 'minimal'"
  countries = ['us', 'de']
  languages = ['en', 'gn']
  company_count = 1
end

taxes = [20, 10, 0]
cost_center_names = ['guest','restaurant','broken']
tax_colors = ['#e3bde1', '#f3d5ab','#ffafcf','#d2f694','#c2e8f3','#c6c6c6']
category_colors = ['#80477d','#ed8b00','#cd0052','#75b10d','#136880','#27343b']
user_colors = ['#80477d','#ed8b00','#cd0052','#75b10d','#136880','#27343b','#BBBBBB','#000000','#d9d43d','#801212']
vendor_printer_labels = ['Bar','Kitchen','Guestroom']
payment_method_names = ['Cash', 'Card', 'Other','Change']
superuser_permissions = SalorHospitality::Application::PERMISSIONS
superuser_permissions.delete('add_option_to_sent_item')
superuser_permissions.delete('login_locking')
superuser_permissions.delete('see_debug')
role_names = {
  'superuser' => {
                  :weight => 0,
                  :permissions => superuser_permissions
                 },
  'owner' => {
              :weight => 1,
              :permissions => [
                               'take_orders',
                               'reactivate_orders',
                               'decrement_items',
                               'delete_items',
                               'cancel_all_items_in_active_order',
                               'finish_orders',
                               'order_notes',
                               'split_items',
                               'move_tables',
                               'assign_order_to_user',
                               'refund',
                               'assign_cost_center',
                               'assign_order_to_booking',
                               'move_order',
                               'move_order_from_invoice_form',
                               'manage_articles',
                               'manage_categories',
                               'manage_statistic_categories',
                               'manage_options',
                               'finish_all_settlements',
                               'finish_own_settlement',
                               'view_all_settlements',
                               'view_settlements_table',
                               'settlement_statistics_taxes',
                               'settlement_statistics_taxes_categories',
                               'manage_business_invoice',
                               'manage_users',
                               'manage_taxes',
                               'manage_cost_centers',
                               'manage_payment_methods',
                               'enter_payment_methods',
                               'manage_tables',
                               'manage_vendors',
                               'manage_cameras',
                               'counter_mode',
                               'see_item_notifications_user_preparation',
                               'see_item_notifications_user_delivery',
                               'see_item_notifications_vendor_preparation',
                               'see_item_notifications_vendor_delivery',
                               'see_item_notifications_static',
                               'manage_pages',
                               'manage_customers',
                               'manage_hotel',
                               'item_scribe',
                               'assign_tables',
                               'download_database',
                               'remote_support',
                               'mobile_show_tools',
                               'receipt_logo',
                               'manage_statistics',
                               'manage_statistics_hotel',
                               'statistics_weekday',
                               'statistics_table',
                               'statistics_payment_method',
                               'statistics_category',
                               'statistics_tax',
                               'allow_exit'
                              ]
             },
  'host' => {
             :weight => 2,
             :permissions => [
                              'take_orders',
                              'reactivate_orders',
                              'decrement_items',
                              'delete_items',
                              'cancel_all_items_in_active_order',
                              'finish_orders',
                              'order_notes',
                              'split_items',
                              'move_tables',
                              'assign_order_to_user',
                              'refund',
                              'assign_cost_center',
                              'assign_order_to_booking',
                              'move_order',
                              'move_order_from_invoice_form',
                              'manage_articles',
                              'manage_categories',
                              'manage_statistic_categories',
                              'manage_options',
                              'finish_all_settlements',
                              'finish_own_settlement',
                              'view_all_settlements',
                              'settlement_statistics_taxes',
                              'settlement_statistics_taxes_categories',
                              'manage_business_invoice',
                              'manage_users',
                              'manage_taxes',
                              'manage_cost_centers',
                              'manage_payment_methods',
                              'enter_payment_methods',
                              'manage_tables',
                              'manage_vendors',
                              'manage_cameras',
                              'counter_mode',
                              'see_item_notifications_user_preparation',
                              'see_item_notifications_user_delivery',
                              'see_item_notifications_vendor_preparation',
                              'see_item_notifications_vendor_delivery',
                              'see_item_notifications_static',
                              'manage_pages',
                              'manage_customers',
                              'item_scribe',
                              'assign_tables',
                              'download_database',
                              'remote_support',
                              'mobile_show_tools',
                              'receipt_logo',
                              'manage_statistics',
                              'manage_statistics_hotel',
                              'statistics_weekday',
                              'statistics_table',
                              'statistics_payment_method',
                              'statistics_category',
                              'statistics_tax',
                              'allow_exit'
                             ]
            },
  'chief_waiter' => {
                     :weight => 3,
                     :permissions => [
                                      'take_orders',
                                      'decrement_items',
                                      'finish_orders',
                                      'split_items',
                                      'move_tables',
                                      'assign_order_to_user',
                                      'refund',
                                      'assign_cost_center',
                                      'move_order',
                                      'move_order_from_invoice_form',
                                      'manage_articles',
                                      'manage_categories',
                                      'manage_statistic_categories',
                                      'manage_options',
                                      'finish_all_settlements',
                                      'finish_own_settlement',
                                      'view_all_settlements',
                                      'settlement_statistics_taxes',
                                      'settlement_statistics_taxes_categories',
                                      'manage_business_invoice',
                                      'manage_users',
                                      'manage_taxes',
                                      'manage_cost_centers',
                                      'manage_payment_methods',
                                      'manage_tables',
                                      'manage_vendors',
                                      'counter_mode',
                                      'see_item_notifications_user_preparation',
                                      'see_item_notifications_user_delivery',
                                      'see_item_notifications_vendor_preparation',
                                      'see_item_notifications_vendor_delivery',
                                      'see_item_notifications_static',
                                      'manage_customers',
                                      'item_scribe',
                                      'assign_tables',
                                      'download_database',
                                      'remote_support',
                                      'mobile_show_tools',
                                      'receipt_logo',
                                      'manage_statistics',
                                      'manage_statistics_hotel',
                                      'statistics_weekday',
                                      'statistics_hour',
                                      'statistics_table',
                                      'statistics_payment_method',
                                      'statistics_category',
                                      'statistics_tax',
                                      'allow_exit'
                                     ]
                    },
  'waiter' =>
{:weight => 4, :permissions => ['take_orders','finish_orders','split_items','move_tables','refund','move_order','manage_articles','manage_categories','manage_statistic_categories','manage_options','finish_all_settlements','finish_own_settlement','view_all_settlements','settlement_statistics_taxes','settlement_statistics_taxes_categories','manage_business_invoice','manage_users','manage_taxes','manage_cost_centers','enter_payment_methods','manage_tables','manage_vendors','manage_customers','assign_tables']},
  'auxiliary_waiter' =>
    {:weight => 5, :permissions => ['take_orders','finish_orders']},
  'terminal' =>
    {:weight => 6, :permissions => ['take_orders']}
}

user_array = {
  'Superuser' => {:role => 'superuser'},
  'Owner' => {:role => 'owner'},
  'Host' => {:role => 'host'},
  'Chief Waiter' => {:role => 'chief_waiter'},
  'Waiter' => {:role => 'waiter'},
  'Auxiliary Waiter' => {:role => 'auxiliary_waiter'},
  'Terminal' => {:role => 'terminal' }
  }

radio_surcharge_names = ['Breakfast','Dinner','Full']
checkbox_surcharge_names = ['Additional Bed']
common_surcharge_names = ['1 Night', '2 Night']
surcharge_amounts = [6, 12, 22, -5]

# Article.delete_all
# BookingItem.delete_all
# Booking.delete_all
# #CashDrawer.delete_all
# #CashRegister.delete_all
# Category.delete_all
# Company.delete_all
# CostCenter.delete_all
# #Coupon.delete_all
# Customer.delete_all
# #Discount.delete_all
# #Group.delete_all
# GuestType.delete_all
# History.delete_all
# Image.delete_all
# #Ingredient.delete_all
# Item.delete_all
# Option.delete_all
# Order.delete_all
# Page.delete_all
# Partial.delete_all
# PaymentMethod.delete_all
# Presentation.delete_all
# Quantity.delete_all
# #Receipt.delete_all
# #Reservation.delete_all
# Role.delete_all
# RoomPrice.delete_all
# RoomType.delete_all
# Room.delete_all
# Season.delete_all
# Settlement.delete_all
# #Stock.delete_all
# SurchargeItem.delete_all
# Surcharge.delete_all
# Table.delete_all
# TaxAmount.delete_all
# TaxItem.delete_all
# Tax.delete_all
# User.delete_all
# VendorPrinter.delete_all
# Vendor.delete_all



company_count.times do |c|
  company = Company.new
  company.name = "Company#{ c }"
  company.identifier = "company#{ c }"
  r = company.save
  puts "Company#{ c } created" if r == true

  countries.size.times do |v|
    vendor = Vendor.new
    vendor.name = "Vendor #{ c } #{ v }"
    vendor.country = countries[v]
    vendor.company = company
    vendor.identifier = "identifier#{c}#{v}"
    r = vendor.save
    puts "Vendor #{ c } #{ v } created" if r == true
    raise "Could not save Vendor: #{ vendor.errors.messages }" if r != true

    presentation_objects = Array.new
    presentation1 = Presentation.create :vendor_id => vendor.id, :company_id => company.id, :name => "Article name #{ c } #{ v }", :description => "just displays name of an article", :markup => "%{{NAME}}", :model => "Article"
    presentation2 = Presentation.create :vendor_id => vendor.id, :company_id => company.id, :name => "Variant list #{ c } #{ v }", :description => "displays names of variants belonging to an article", :markup => "%{{LOOP BEGIN QUANTITIES}}\r\n%{{LOOP.PREFIX}}<br/>\r\n%{{END}}", :model => "Article"
    presentation3 = Presentation.create :vendor_id => vendor.id, :company_id => company.id, :name => "Generic Text Blurb #{ c } #{ v }", :description => "displays any entered text", :markup => "%{{BLURB}}", :model => "Presentation"
    presentation4 = Presentation.create :vendor_id => vendor.id, :company_id => company.id, :name => "Category Title #{ c } #{ v }", :description => "just displays name of category", :markup => "%{{NAME}}", :model => "Category"
    presentation5 = Presentation.create :vendor_id => vendor.id, :company_id => company.id, :name => "Article full #{ c } #{ v }", :description => "displays Article with name, price and image", :markup => "<b>%{{NAME}}</b><br />\r\nEUR %{{PRICE}}\r\n%{{IF IMAGE}}\r\n<br/>\r\n<img src=\"%{{IMAGE}}\">\r\n%{{END}}", :model => "Article"
    presentation6 = Presentation.create :vendor_id => vendor.id, :company_id => company.id, :name => "All articles of a category #{ c } #{ v }", :description => "displays All articles of a category, including descriptions", :markup => "<table width=300 border=0>\r\n%{{LOOP BEGIN ARTICLES}}\r\n<tr>\r\n<td><br/><b><big>%{{LOOP.NAME}}</big></b></td>\r\n<td width=100 rowspan=2 align=right><br/><i>EUR %{{LOOP.PRICE}}</i></td>\r\n</tr>\r\n<tr>\r\n<td><br/><small>%{{LOOP.DESCRIPTION}}</small></td>\r\n</tr>\r\n%{{END}}\r\n</table>", :model => "Category"
    presentation_objects << presentation1
    presentation_objects << presentation2
    presentation_objects << presentation3
    presentation_objects << presentation4
    presentation_objects << presentation5
    presentation_objects << presentation6
    puts "Presentations #{ c } #{ v } created"

    partial_objects = Array.new
    partial1 = Partial.create "left"=>230, "top"=>-19, "presentation_id"=>presentation3.id, "blurb"=>"Holiday Offer", "active"=>true, "hidden"=>nil, "model_id"=>4, "font"=>"Rolina", "size"=>400, "image_size"=>nil, "color"=>"#e67373", "width"=>nil, "align"=>nil, "company_id"=>company.id, "vendor_id"=>vendor.id
    partial2 = Partial.create "left"=>117, "top"=>187, "presentation_id"=>presentation6.id, "blurb"=>nil, "active"=>true, "hidden"=>nil, "model_id"=>1, "font"=>nil, "size"=>150, "image_size"=>250, "color"=>"#c3d3e6", "width"=>800, "align"=>nil, "company_id"=>company.id, "vendor_id"=>vendor.id
    partial3 = Partial.create "left"=>583, "top"=>242, "presentation_id"=>presentation2.id, "blurb"=>nil, "active"=>true, "hidden"=>nil, "model_id"=>2, "font"=>nil, "size"=>200, "image_size"=>nil, "color"=>"#95e6e1", "width"=>nil, "align"=>nil, "company_id"=>company.id, "vendor_id"=>vendor.id
    partial4 = Partial.create "left"=>246, "top"=>165, "presentation_id"=>presentation5.id, "blurb"=>nil, "active"=>true, "hidden"=>nil, "model_id"=>1, "font"=>"Rolina", "size"=>400, "image_size"=>nil, "color"=>"#7579c9", "width"=>nil, "align"=>"center", "company_id"=>company.id, "vendor_id"=>vendor.id
    partial5 = Partial.create "left"=>203, "top"=>21, "presentation_id"=>presentation4.id, "blurb"=>nil, "active"=>true, "hidden"=>nil, "model_id"=>1, "font"=>"aaaiight", "size"=>500, "image_size"=>nil, "color"=>"#5b3bdb", "width"=>nil, "align"=>nil, "company_id"=>company.id, "vendor_id"=>vendor.id
    partial_objects << partial1
    partial_objects << partial2
    partial_objects << partial3
    partial_objects << partial4
    partial_objects << partial5
    puts "Partials #{ c } #{ v } created"

    pages_objects = Array.new
    page1 = Page.create "color"=>"#1f1818", "company_id"=>company.id, "vendor_id"=>vendor.id
    page2 = Page.create "color"=>"#8adea7", "company_id"=>company.id, "vendor_id"=>vendor.id

    page1.partials << partial1
    page1.partials << partial2
    page1.partials << partial3
    page1.save

    page2.partials << partial4
    page2.partials << partial5
    page2.save
    puts "Pages #{ c } #{ v } created"


    tax_objects = Array.new
    letters = ['A','B','C']
    taxes.size.times do |i|
      tax = Tax.new :name => "#{ taxes[i] } #{ c } #{ v }", :letter => letters[i], :percent => taxes[i], :color => tax_colors[i]
      tax.company = company
      tax.vendor = vendor
      r = tax.save
      tax_objects << tax
      puts "Tax #{ taxes[i] } #{ c } #{ v } created" if r == true
      raise "Could not save Tax" if r != true
    end

    cash_register_objects = Array.new
    2.times do |i|
      cash_register = CashRegister.new :name => "CashRegister #{ c } #{ v } #{ i }"
      cash_register.company = company
      cash_register.vendor = vendor
      r = cash_register.save
      cash_register_objects << cash_register
      puts "CashRegister #{ c } #{ v } #{ i } created" if r == true
      raise "Could not save CashRegister" if r != true
    end

    vendor_printer_objects = Array.new
    vendor_printer_labels.size.times do |i|
      vendor_printer = VendorPrinter.new :name => vendor_printer_labels[i], :path => "/tmp/vendor_printer_#{ c }_#{ v }_#{ i }.txt"
      vendor_printer.company = company
      vendor_printer.vendor = vendor
      r = vendor_printer.save
      vendor_printer_objects << vendor_printer
      puts "VendorPrinter #{ c } #{ v } #{ i } created" if r == true
      raise "Could not save VendorPrinter" if r != true
    end

    role_objects = Array.new
    role_names.to_a.size.times do |i|
      role = Role.new :name => role_names.to_a[i][0], :permissions => role_names.to_a[i][1][:permissions], :weight => role_names.to_a[i][1][:weight]
      role.company = company
      role.vendor = vendor
      r = role.save
      role_objects << role
      puts "Role #{ role_names.to_a[i][0] } #{ c } #{ v } #{ i } created" if r == true
    end

    table_objects = Array.new
    5.times do |i|
      table = Table.new :name => "T#{ c }#{ v }#{ i }", :left => 50 * i + 50, :top => 50 * i + 50, :left_mobile => 50 * i + 50, :top_mobile => 100 * i + 50, :width => 70, :height => 70
      table.company = company
      table.vendor = vendor
      table.booking_table = true if i == 3
      r = table.save
      table_objects << table
      puts "Table #{ c } #{ v } #{ i } created" if r == true
    end

    cost_center_objects = Array.new
    cost_center_names.size.times do |i|
      cost_center = CostCenter.new :name => "CC #{ c }#{ v }#{ i }"
      cost_center.company = company
      cost_center.vendor = vendor
      r = cost_center.save
      cost_center_objects << cost_center
      puts "Cost Center #{ c } #{ v } #{ i } created" if r == true
    end

    customer_objects = Array.new
    5.times do |i|
      customer = Customer.new :first_name => "Bob#{c}#{v}#{i}", :last_name => "Doe#{c}#{v}#{i}", :company_name => "Company#{c}#{v}#{i}", :address => "Address#{c}#{v}#{i}", :m_points => 100-i, :login => "customer#{c}#{v}#{i}", :password => "customer#{c}#{v}#{i}", :default_table_id => table_objects[i].id
      customer.company = company
      customer.vendor = vendor
      r = customer.save
      customer_objects << customer
      puts "Customer #{ c } #{ v } #{ i } created" if r == true
    end

    payment_method_objects = Array.new
    payment_method_names.size.times do |i|
      pm = PaymentMethod.new :name => "#{ payment_method_names[i] }#{c}#{v}#{i}", :cash => (payment_method_names[i] == 'Cash') ? true : false, :change => (payment_method_names[i] == 'Change') ? true : false
      pm.company = company
      pm.vendor = vendor
      r = pm.save
      payment_method_objects << pm
      puts "PaymentMethod #{ c } #{ v } #{ i } created" if r == true
    end

    user_objects = Array.new
    user_array.to_a.size.times do |i|
      user = User.new :login => "#{ user_array.to_a[i][0] } #{ c } #{ v } #{ i }", :title => "#{ user_array.to_a[i][0] }", :password => "#{ c }#{ v }#{ i }", :language => languages[v], :color => user_colors[i]
      user.company = company
      user.vendors << vendor
      user.default_vendor_id = vendor.id
      user.tables = table_objects
      user.role = role_objects[i]
      user.role_weight = role_objects[i].weight
      r = user.save
      user_objects << user
      puts "User #{ user_array.to_a[i][0] } #{ c } #{ v } #{ i } created" if r == true

      cash_drawer = CashDrawer.new :name => "CashDrawer #{ c } #{ v } #{ i }"
      cash_drawer.company = company
      cash_drawer.vendor = vendor
      cash_drawer.user = user
      r = cash_drawer.save
      puts "CashDrawer #{ c } #{ v } #{ i } created" if r == true
    end

    category_labels.size.times do |i|
      category = Category.new :name => category_labels[i], :icon => category_icons[i], :color => category_colors[rand(category_colors.size)]
      category.company = company
      category.vendor = vendor
      category.preparation_user_id = user_objects[1].id
      category.vendor_printer = vendor_printer_objects.first
      r = category.save
      puts "Category #{ c } #{ v } #{ i } created" if r == true

      2.times do |o|
        option = Option.new :name => "Option#{ c }#{ v }#{ i }#{ o }", :price => (rand(3) + 1).to_f
        option.categories << category
        option.company = company
        option.vendor = vendor
        r = option.save
        puts "Option #{ c } #{ v } #{ i } #{ o } created" if r == true
      end
        
      2.times do |a|
        article = Article.new :name => "Article#{ c }#{ v }#{ i }#{ a }", :price => rand(30) + 1, :active => true
        article.taxes = [tax_objects[rand(3)]]
        article.category = category
        article.company = company
        article.vendor = vendor
        r = article.save
        puts "Article #{ c } #{ v } #{ i } #{ a } created" if r == true
        
        if a > 0
          2.times do |q|
            quantity = Quantity.new :prefix => "#{c}#{v}#{i}#{a}#{q}", :postfix => 'post', :price => rand(10) + 1
            quantity.article = article
            quantity.category = category
            quantity.company = company
            quantity.vendor = vendor
            r = quantity.save
            puts "Quantity #{ c } #{ v } #{ i } #{ a } #{ q } created" if r == true
          end
        end
      end
    end

    puts " Creating Example Hotel Tax #{c} #{v}"
    #local_tax = Tax.create :name => "Local Tax #{c} #{v}", :percent => 1, :vendor_id => vendor.id, :company_id => company.id, :letter => "D"
    room_type_objects = Array.new
    guest_type_objects = Array.new
    4.times do |i|
      puts " Creating Example RoomType #{c} #{v} #{i}"
      rt = RoomType.create :name => "RoomType #{c} #{v} #{i}", :vendor_id => vendor.id, :company_id => company.id
      room_type_objects << rt
      puts " Creating Example Room #{c} #{v} #{i}"
      Room.create :name => "Room#{i}", :room_type_id => rt.id, :vendor_id => vendor.id, :company_id => company.id
      puts " Creating Example GuestType #{c} #{v} #{i}"
      gt = GuestType.new :name => "GuestType #{c} #{v} #{i}", :vendor_id => vendor.id, :company_id => company.id
      gt.taxes << tax_objects[0]
      gt.save
      guest_type_objects << gt
    end
    puts " Creating Example Seasons for #{c} #{v}"
    s1 = Season.new :name => 'Summer', :from_date => Date.parse('2012-06-21'), :to_date => Date.parse('2012-09-20'), :vendor_id => vendor.id, :company_id => company.id, :color => "#d6c951"
    s1.save
    s1.calculate_duration
    s2 = Season.new :name => 'Autumn', :from_date => Date.parse('2012-09-21'), :to_date => Date.parse('2012-12-20'), :vendor_id => vendor.id, :company_id => company.id, :color => "#8f0303"
    s2.save
    s1.calculate_duration
    s3 = Season.new :name => 'Winter', :from_date => Date.parse('2012-12-21'), :to_date => Date.parse('2012-03-20'), :vendor_id => vendor.id, :company_id => company.id, :is_master => true, :color => "#39c4d4"
    s3.save
    s1.calculate_duration
    s4 = Season.new :name => 'Spring', :from_date => Date.parse('2012-03-21'), :to_date => Date.parse('2012-06-20'), :vendor_id => vendor.id, :company_id => company.id, :color => "#39d467"
    s4.save
    s1.calculate_duration
    season_objects = [s1,s2,s3,s4]

    4.times do |i|
      4.times do |j|
        4.times do |k|
          puts " Creating Example RoomPrice #{c} #{v} #{i} #{j} #{k}"
          RoomPrice.create :season_id => season_objects[k].id, :room_type_id => room_type_objects[i].id, :guest_type_id => guest_type_objects[j].id, :base_price => (2 * i + 3 * j + 5 * k) * 10 + 3, :vendor_id => vendor.id, :company_id => company.id
        end
      end
    end

    season_objects.size.times do |x|
      guest_type_objects.size.times do |y|
        radio_surcharge_names.size.times do |z|
          puts " Creating Example Radio Surcharge #{radio_surcharge_names[z]}"
          surcharge = Surcharge.new :name => radio_surcharge_names[z], :vendor_id => vendor.id, :company_id => company.id, :season_id => season_objects[x].id, :guest_type_id => guest_type_objects[y].id, :radio_select => true
          tax_amount = TaxAmount.create :vendor_id => vendor.id, :company_id => company.id, :amount => 1 + x + y + z, :tax_id => tax_objects[rand(3)].id
          surcharge.tax_amounts = [tax_amount]
          surcharge.save
          surcharge.calculate_totals
        end
        checkbox_surcharge_names.size.times do |z|
          puts " Creating Example Checkbox Surcharge #{checkbox_surcharge_names[z]}"
          surcharge = Surcharge.create :name => checkbox_surcharge_names[z], :vendor_id => vendor.id, :company_id => company.id, :season_id => season_objects[x].id, :guest_type_id => guest_type_objects[y].id
          tax_amount = TaxAmount.create :vendor_id => vendor.id, :company_id => company.id, :amount => 1 + x + y + z, :tax_id => tax_objects[rand(3)].id
          surcharge.tax_amounts = [tax_amount]
          surcharge.save
          surcharge.calculate_totals
        end
      end
      common_surcharge_names.size.times do |z|
        puts " Creating Example Common Surcharge #{common_surcharge_names[z]}"
        surcharge = Surcharge.create :name => common_surcharge_names[z], :vendor_id => vendor.id, :company_id => company.id, :season_id => season_objects[x].id, :guest_type_id => nil
        tax_amount = TaxAmount.create :vendor_id => vendor.id, :company_id => company.id, :amount => 3 + x + z, :tax_id => tax_objects[rand(3)].id
        surcharge.tax_amounts = [tax_amount]
        surcharge.save
        surcharge.calculate_totals
      end
    end
    vendor.update_cache
  end
end
