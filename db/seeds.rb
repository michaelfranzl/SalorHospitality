category_labels = ['Starters','Main Dish','Desserts','Rose Wine','Red Wine','Digestiv','Alcohol','Coffee','Tea','Tobacco','Beer','Aperitiv','White Wine','Side Dish','Divers']
category_icons = ['starter','maindish','dessert','rosewineglass','redwineglass','digestif','nonalcoholics','coffee','teapot','cigarette','beer','aperitif','whitewineglass','sidedish','blank']
countries = ['en','de','at','cc']
taxes = [0, 10, 20]
tax_colors = ['#e3bde1', '#f3d5ab','#ffafcf','#d2f694','#c2e8f3','#c6c6c6']
category_colors = ['#80477d','#ed8b00','#cd0052','#75b10d','#136880','#27343b']
user_colors = ['#80477d','#ed8b00','#cd0052','#75b10d','#136880','#27343b','#BBBBBB','#000000','#d9d43d','#801212']
vendor_printer_labels = ['Bar','Kitchen','Guestroom']
user_array = {
  'Superuser' => ['take_orders','decrement_items','finish_orders','split_items','move_tables','make_storno','assign_cost_center','move_order',    'change_waiter','manage_articles_categories_options','finish_all_settlements','finish_own_settlement','view_all_settlements','manage_business_invoice',    'view_statistics','manage_users','manage_settings'],
  'Owner' => ['take_orders','decrement_items','finish_orders','split_items','move_tables','make_storno','assign_cost_center','move_order',    'change_waiter','manage_articles_categories_options','finish_all_settlements','finish_own_settlement','view_all_settlements','manage_business_invoice',    'view_statistics','manage_users','manage_settings'],
  'Host' => ['take_orders','decrement_items','finish_orders','split_items','move_tables','make_storno','assign_cost_center','move_order',    'change_waiter','manage_articles_categories_options'],
  'Chief Waiter' => ['take_orders','decrement_items','finish_orders','split_items','move_tables','make_storno','finish_own_settlement'],
  'Waiter' => ['take_orders','decrement_items','finish_orders','split_items','finish_own_settlement'],
  'Auxiliary Waiter' => ['take_orders','decrement_items','finish_orders'],
  'Restaurant' => ['take_orders']
  }




2.times do |c|
  company = Company.new :name => "Company #{ c }"
  r = company.save
  puts "Company #{ c } created" if r == true

  countries.size.times do |v|
    vendor = Vendor.new :name => "Vendor #{ c } #{ v }", :country => countries[v]
    vendor.company = company
    r = vendor.save
    puts "Vendor #{ c } #{ v } created" if r == true


    tax_objects = Array.new
    taxes.size.times do |i|
      tax = Tax.new :name => "#{ taxes[i] } #{ c } #{ v }", :letter => taxes[i], :percent => taxes[i], :color => tax_colors[i]
      tax.company = company
      tax.vendor = vendor
      r = tax.save
      tax_objects << tax
      puts "Tax #{ taxes[i] } #{ c } #{ v } created" if r == true
    end

    cash_register_objects = Array.new
    2.times do |i|
      cash_register = CashRegister.new :name => "CashRegister #{ c } #{ v } #{ i }"
      cash_register.company = company
      cash_register.vendor = vendor
      r = cash_register.save
      cash_register_objects << cash_register
      puts "CashRegister #{ c } #{ v } #{ i } created" if r == true
    end

    vendor_printer_objects = Array.new
    vendor_printer_labels.size.times do |i|
      vendor_printer = VendorPrinter.new :name => vendor_printer_labels[i], :path => "/tmp/vendor_printer_#{ c }_#{ v }_#{ i }.txt"
      vendor_printer.company = company
      vendor_printer.vendor = vendor
      r = vendor_printer.save
      vendor_printer_objects << vendor_printer
      puts "VendorPrinter #{ c } #{ v } #{ i } created" if r == true
    end

    cash_register_objects = Array.new
    2.times do |i|
      cash_register = CashRegister.new :name => "CashRegister #{ c } #{ v } #{ i }"
      cash_register.company = company
      cash_register.vendor = vendor
      r = cash_register.save
      cash_register_objects << cash_register
      puts "CashRegister #{ c } #{ v } #{ i } created" if r == true
    end

    role_objects = Array.new
    user_array.to_a.size.times do |i|
      role = Role.new :name => "#{ user_array.to_a[i][0] } #{ c } #{ v } #{ i }", :permissions => user_array.to_a[i][1]
      role.company = company
      role.vendor = vendor
      r = role.save
      role_objects << role
      puts "Role #{ user_array.to_a[i][0] } #{ c } #{ v } #{ i } created" if r == true
    end

    table_objects = Array.new
    3.times do |i|
      table = Table.new :name => "T#{ c }#{ v }#{ i }", :left => 50 * i, :top => 50 * i, :width => 70, :height => 70, :abbreviation => "T#{ c }#{ v }#{ i }"
      table.company = company
      table.vendor = vendor
      r = table.save
      table_objects << table
      puts "Table #{ c } #{ v } #{ i } created" if r == true
    end

    user_objects = Array.new
    user_array.to_a.size.times do |i|
      user = User.new :login => "#{ user_array.to_a[i][0] } #{ c } #{ v } #{ i }", :title => "#{ user_array.to_a[i][0] }", :password => "#{ c }#{ v }#{ i }", :language => 'en', :color => user_colors[i]
      user.company = company
      user.vendors << vendor
      user.tables = table_objects
      user.role = role_objects[i]
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
      category = Category.new :name => category_labels[i], :tax_id => tax_objects[rand(tax_objects.size)], :icon => category_icons[i], :color => category_colors[rand(category_colors.size)]
      category.company = company
      category.vendor = vendor
      category.preparation_user_id = user_objects.first.id
      category.vendor_printer = vendor_printer_objects.first
      r = category.save
      puts "Category #{ c } #{ v } #{ i } created" if r == true

      2.times do |a|
        article = Article.new :name => "Article#{ c }#{ v }#{ i }#{ a }", :price => rand(30), :active => true
        article.category = category
        article.company = company
        article.vendor = vendor
        r = article.save
        puts "Article #{ c } #{ v } #{ i } #{ a } created" if r == true
        
        if a > 0
          2.times do |q|
            quantity = Quantity.new :prefix => "#{c}#{v}#{i}#{a}#{q}", :price => rand(10)
            quantity.article = article
            quantity.company = company
            quantity.vendor = vendor
            r = quantity.save
            puts "Quantity #{ c } #{ v } #{ i } #{ a } #{ q } created" if r == true
          end
        end
      end
    end
  end
end
