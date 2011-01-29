class OrdersController < ApplicationController

  skip_before_filter :fetch_logged_in_user, :only => [:login]

  def index
    @tables = Table.all
    @categories = Category.find(:all, :order => :sort_order)
    session[:admin_interface] = !ipod? # admin panel per default on on workstation
  end

  def login
    @current_user = User.find_by_login_and_password(params[:login], params[:password])
    if @current_user
      @tables = Table.all
      @categories = Category.find(:all, :order => :sort_order)
      session[:user_id] = @current_user
      session[:admin_interface] = !ipod? # admin panel per default on on workstation
      render 'login_successful'
    else
      @users = User.all
      @errormessage = t :wrong_password
      render 'login_wrong'
    end
  end

  def logout
    session[:user_id] = @current_user = nil
    render 'go_to_login'
  end

  def statusupdate_tables
    @tables = Table.all
    @last_finished_order = Order.find_all_by_finished(true).last
  end

  def show
    @client_data = File.exist?('client_data.yaml') ? YAML.load_file( 'client_data.yaml' ) : {}
    if params[:id] != 'last'
      @order = Order.find(params[:id])
    else
      @order = Order.find_all_by_finished(true).last
    end
    @previous_order, @next_order = neighbour_orders(@order)
    respond_to do |wants|
      wants.html
      wants.bon { render :text => generate_escpos_invoice(@order) }
    end
  end

  def unsettled
    @unsettled_orders = Order.find(:all, :conditions => { :settlement_id => nil, :finished => true })
    unsettled_userIDs = Array.new
    @unsettled_orders.each do |uo|
      unsettled_userIDs << uo.user_id
    end
    unsettled_userIDs.uniq!
    @unsettled_users = User.find(:all, :conditions => { :id => unsettled_userIDs })
    flash[:notice] = t(:there_are_no_open_settlements) if @unsettled_users.empty?
  end

  def items
    respond_to do |wants|
      wants.bon { render :text => generate_escpos_items(:drink) }
    end
  end

  def split_invoice_all_at_once
    @order = Order.find(params[:id])
    @order.update_attributes(params[:order])
    @cost_centers = CostCenter.find_all_by_active(true)
    items_for_split_invoice = Item.find(:all, :conditions => { :order_id => @order.id, :partial_order => true })
    make_split_invoice(@order, items_for_split_invoice, :all)
    @orders = Order.find_all_by_finished(false, :conditions => { :table_id => @order.table_id })
    render 'split_invoice'
  end

  def split_invoice_one_at_a_time
    @item_to_split = Item.find_by_id(params[:id]) # find item on which was clicked
    @order = @item_to_split.order
    @cost_centers = CostCenter.find_all_by_active(true)
    make_split_invoice(@order, [@item_to_split], :one)
    @orders = Order.find_all_by_finished(false, :conditions => { :table_id => @order.table_id })
    render 'split_invoice'
  end

  def separate_item
    @item=Item.find(params[:id])
    @separated_item = @item.clone
    @separated_item.count = 1
    @item.count -= 1
    @item.count == 0 ? @item.delete : @item.save
    @separated_item.save
    @order = @item.order
    @previous_order, @next_order = neighbour_orders(@order)
    respond_to do |wants|
      wants.js { render 'display_storno' }
    end
  end

  def toggle_admin_interface
    if session[:admin_interface]
      session[:admin_interface] = !session[:admin_interface]
    else
      session[:admin_interface] = true
    end
    @tables = Table.all
  end

  def print_and_finish
    @order = Order.find params[:id]
    if not @order.finished and ipod?
      @order.user = @current_user
      @order.created_at = Time.now
    end

    if @order.order # unlink any parent relationships
      @order.items.each do |item|
        item.item.update_attribute( :item_id, nil ) if item.item
        item.update_attribute( :item_id, nil )
      end
      @order.order.items.each do |item|
        item.item.update_attribute( :item_id, nil ) if item.item
        item.update_attribute( :item_id, nil )
      end
      @order.order.update_attribute( :order_id, nil )
      @order.update_attribute( :order_id, nil )
    end

    File.open('order.escpos', 'w') { |f| f.write(generate_escpos_invoice(@order)) }
    `cat order.escpos > /dev/ttyPS#{ params[:port] }`

    justfinished = false
    if not @order.finished
      @order.finished = true
      @order.printed_from = "#{ request.remote_ip } on printer #{ params[:port] }"
      justfinished = true
      @order.save
    end

    @orders = Order.find(:all, :conditions => { :table_id => @order.table, :finished => false })
    @order.table.update_attribute :user, nil if @orders.empty?
    @cost_centers = CostCenter.find_all_by_active(true)

    respond_to do |wants|
      wants.html { redirect_to order_path @order }
      wants.js {
        if not justfinished
          render :nothing => true
        elsif not @orders.empty?
          render('go_to_invoice_form')
        else
          @tables = Table.all
          render('go_to_tables')
        end
      }
    end
  end

  def go_to_table # go_to_invoice(s) OR go_to_order_form
    @table = Table.find(params[:id])
    @cost_centers = CostCenter.find_all_by_active(true)
    @orders = Order.find(:all, :conditions => { :table_id => @table.id, :finished => false }) # @orders array needed for view 'go_to_invoice_form'
    if @orders.size > 1
      render 'go_to_invoice_form'
    else
      @order = @orders.first
      render 'go_to_order_form'
    end
  end

  def go_to_order_form # to be called only with /id
    @order = Order.find(params[:id])
    @table = @order.table
    @cost_centers = CostCenter.find_all_by_active(true)
    render 'go_to_order_form'
  end

  def receive_order_attributes_ajax
    @cost_centers = CostCenter.find_all_by_active(true)
    if not params[:order_action] == 'cancel_and_go_to_tables'
      if params[:order][:id] == 'add_offline_items_to_order'
        @order = Order.find(:all, :conditions => { :finished => false, :table_id => params[:order][:table_id] }).first
      else
        @order = Order.find(params[:order][:id]) if not params[:order][:id].empty?
      end

      if @order
        #similar to update
        @order.update_attributes(params[:order])
        @order.reload
        @order.table.update_attribute :user, @order.user
      else
        #similar to create
        # create new order OR (if order exists already on table) add items to existing order
        @order = Order.new(params[:order])
        @order.sum = calculate_order_sum @order
        @order.cost_center = @cost_centers.first
        @order.save
        @order.table.update_attribute :user, @order.user
      end
      process_order(@order)
    end
    conditional_redirect_ajax(@order)
  end

  def storno
    @order = Order.find(params[:id])
    @previous_order, @next_order = neighbour_orders(@order)
    @order.update_attributes(params[:order])
    items_for_storno = Item.find(:all, :conditions => { :order_id => @order.id, :storno_status => 1 })
    make_storno(@order, items_for_storno)
    @order = Order.find(params[:id]) # re-read
    respond_to do |wants|
      wants.html
      wants.js { render 'display_storno' }
    end
  end

  def last_invoices
    @last_orders = Order.find(:all, :conditions => { :finished => true }, :limit => 10, :order => 'created_at DESC')
  end


  private

    def process_order(order)
      if order.items.size.zero?
        order.delete
        order.table.update_attribute :user, nil
        return
      end

      order.update_attribute( :sum, calculate_order_sum(order) )

      group_identical_items(order)

      File.open('bar.escpos', 'w') { |f| f.write(generate_escpos_items(order, :drink)) }
      File.open('kitchen.escpos', 'w') { |f| f.write(generate_escpos_items(order, :food)) }
      File.open('kitchen-takeaway.escpos', 'w') { |f| f.write(generate_escpos_items(order, :takeaway)) }

      `cat bar.escpos > /dev/ttyPS1` #1 = Bar
      `cat kitchen.escpos > /dev/ttyPS0` #0 = Kitchen
      `cat kitchen-takeaway.escpos > /dev/ttyPS0` #0 = Kitchen
    end

    def conditional_redirect_ajax(order)
      @tables = Table.all
      render('go_to_tables') and return if not order or order.destroyed?
      case params[:order_action]
        when 'save_and_go_to_tables'
          render 'go_to_tables'
        when 'cancel_and_go_to_tables'
          render 'go_to_tables'
        when 'save_and_go_to_invoice'
          @orders = Order.find(:all, :conditions => { :table_id => order.table.id, :finished => false })
          render 'go_to_invoice_form'
        when 'move_order_to_table'
          move_order_to_table(order, params[:target_table])
          @tables = Table.all
          render 'go_to_tables'
      end
    end

    def move_order_to_table(order,target_table_id)
      @target_order = Order.find(:all, :conditions => { :table_id => target_table_id, :finished => false }).first
      if @target_order
        # mix items into existing order
        order.items.each do |i|
          i.update_attribute :order, @target_order
        end
        @target_order.update_attribute( :sum, calculate_order_sum(@target_order) )
        group_identical_items(@target_order)
        order.destroy
      else
        # move order to empty table
        order.update_attribute :table_id, target_table_id
      end

      # change table users and colors
      unfinished_orders_on_this_table = Order.find(:all, :conditions => { :table_id => order.table.id, :finished => false })
      order.table.update_attribute :user, nil if unfinished_orders_on_this_table.empty?
      unfinished_orders_on_target_table = Order.find(:all, :conditions => { :table_id => target_table_id, :finished => false })
      Table.find(target_table_id).update_attribute :user, order.user
    end

    def group_identical_items(o)
      items = o.items
      n = items.size - 1
      0.upto(n) do |i|
        (i+1).upto(n) do |j|
          if (items[i].article_id  == items[j].article_id and
              items[i].quantity_id == items[j].quantity_id and
              items[i].price       == items[j].price and
              items[i].comment     == items[j].comment
             )
            items[i].count += items[j].count
            items[i].printed_count += items[j].printed_count
            items[j].delete
            items[i].save
          end
        end
      end
    end

    def neighbour_orders(order)
      orders = Order.find_all_by_finished(true)
      idx = orders.index(order)
      previous_order = orders[idx-1]
      previous_order = order if previous_order.nil?
      next_order = orders[idx+1]
      next_order = order if next_order.nil?
      return previous_order, next_order
    end

    def reduce_stocks(order)
      order.items.each do |item|
        item.article.ingredients.each do |ingredient|
          ingredient.stock.balance -= item.count * ingredient.amount
          ingredient.stock.save
        end
      end
    end


    def make_split_invoice(parent_order, split_items, mode)
      return if split_items.nil? or split_items.empty?
      if parent_order.order # if there already exists one child order, use it for the split invoice
        split_invoice = parent_order.order
      else # create a brand new split invoice, and make it belong to the parent order
        split_invoice = parent_order.clone
        split_invoice.save
        parent_order.order = split_invoice  # make an association between parent and child
        split_invoice.order = parent_order  # ... and vice versa
      end
      case mode
        when :all
          split_items.each do |i|
            i.order_id = split_invoice.id # move item to the new order
            i.partial_order = false # after the item has moved to the new order, leave it alone
            i.save
          end
        when :one
          parent_item = split_items.first # in this mode there will only single items to split
          if parent_item.item
            split_item = parent_item.item
          else
            split_item = parent_item.clone
            split_item.count = 0
            split_item.printed_count = 0
            split_item.save
            parent_item.item = split_item # make an association between parent and child
            split_item.item = parent_item # ... and vice versa
          end
          split_item.order = split_invoice # this is the actual moving to the new order
          split_item.count += 1
          split_item.printed_count += 1
          split_item.save
          parent_item.count -= 1
          parent_item.printed_count -= 1
          parent_item.count == 0 ? parent_item.delete : parent_item.save
      end
      parent_order = Order.find(parent_order.id) # re-read

      parent_order.delete if parent_order.items.empty?
      parent_order.update_attribute( :sum, calculate_order_sum(parent_order) ) if not parent_order.items.empty?
      split_invoice.update_attribute( :sum, calculate_order_sum(split_invoice) )
    end
    
    # storno_status: 1 = marked for storno, 2 = is storno clone, 3 = storno original
    #
    def make_storno(order, items_for_storno)
      return if items_for_storno.empty?
      items_for_storno.each do |item|
        next if item.storno_status == 3 # only one storno allowed per item
        storno_item = item.clone
        storno_item.save
        storno_item.update_attribute :storno_status, 2 # tis is a storno clone
        item.update_attribute :storno_status, 3 # this is a storno original
      end
    end
    
    
    def calculate_order_sum(order)
      subtotal = 0
      order.items.each do |item|
        p = item.real_price
        sum = item.count * p
        subtotal += item.count * p
      end
      return subtotal
    end


    def generate_escpos_invoice(order)
      client_data = File.exist?('client_data.yaml') ? YAML.load_file( 'client_data.yaml' ) : { :name => '', :subtitle => '', :address => '', :taxnumber => '', :slogan1 => '', :slogan2 => '', :internet => '' }

      header =
      "\e@"     +  # Initialize Printer
      "\ea\x01" +  # align center

      "\e!\x38" +  # doube tall, double wide, bold
      client_data[:name] + "\n" +

      "\e!\x01" +  # Font B
      "\n" + client_data[:subtitle] + "\n" +
      "\n" + client_data[:address] + "\n\n" +
      client_data[:taxnumber] + "\n\n" +

      "\ea\x00" +  # align left
      "\e!\x01" +  # Font B
      t('served_by_X_on_table_Y', :waiter => order.user.title, :table => order.table.name) + "\n" +
      t('invoice_numer_X_at_time', :number => order.id, :datetime => l(order.created_at, :format => :long)) + "\n\n" +

      "\e!\x00" +  # Font A
      "               Artikel    EP    Stk   GP\n"

      sum_taxes = Array.new(Tax.count, 0)
      subtotal = 0
      list_of_items = ''
      order.items.each do |item|
        p = item.real_price
        p = -p if item.storno_status == 2
        sum = item.count * p
        subtotal += sum
        tax_id = item.article.category.tax.id
        sum_taxes[tax_id-1] += sum
        label = item.quantity ? "#{ item.quantity.prefix } #{ item.quantity.article.name } #{ item.quantity.postfix } #{ item.comment }" : item.article.name

        label.gsub!(/ö/,"oe") #ö
        label.gsub!(/ä/,"ae") #ä
        label.gsub!(/ü/,"ue") #ü
        label.gsub!(/ß/,"sz") #ß
        label.gsub!(/Ö/,"Oe") #Ö
        label.gsub!(/Ä/,"Ae") #Ä
        label.gsub!(/Ü/,"Ue") #Ü
        label.gsub!(/é/,"e")  #Ü

        #label = Iconv.conv('ISO-8859-15//TRANSLIT','UTF-8', label)
        list_of_items += "%c %20.20s %7.2f %3u %7.2f\n" % [tax_id+64, label, p, item.count, sum]
        #list_of_items = Iconv.conv('UTF-8','ISO-8859-15',list_of_items)
      end

      sum =
      "                               -----------\r\n" +
      "\e!\x18" + # double tall, bold
      "\ea\x02" +  # align right
      "SUMME:   EUR %.2f\n\n" % subtotal.to_s +
      "\ea\x01" +  # align center
      "\e!\x01" # Font A

      tax_header = "          netto     USt.  brutto\n"

      list_of_taxes = ''
      Tax.all.each do |tax|
        tax_id = tax.id - 1
        next if sum_taxes[tax_id] == 0
        fact = tax.percent/100.00
        net = sum_taxes[tax_id]/(1.00+fact)
        gro = sum_taxes[tax_id]
        vat = gro-net

        list_of_taxes += "%c: %2i%% %7.2f %7.2f %8.2f\n" % [tax.id+64,tax.percent,net,vat,gro]
      end

      footer = 
      "\ea\x01" +  # align center
      "\e!\x00" + # font A
      "\n" + client_data[:slogan1] + "\n" +
      "\e!\x08" + # emphasized
      "\n" + client_data[:slogan2] + "\n" +
      client_data[:internet] + "\n\n\n\n\n\n\n" + 
      "\x1DV\x00" # paper cut

      output = header + list_of_items + sum + tax_header + list_of_taxes + footer

      output = Iconv.conv('ISO-8859-15','UTF-8',output)
      output.gsub!(/\xE4/,"\x84") #ä
      output.gsub!(/\xFC/,"\x81") #ü
      output.gsub!(/\xF6/,"\x94") #ö
      output.gsub!(/\xC4/,"\x8E") #Ä
      output.gsub!(/\xDC/,"\x9A") #Ü
      output.gsub!(/\xD6/,"\x99") #Ö
      output.gsub!(/\xDF/,"\xE1") #ß
      output.gsub!(/\xE9/,"\x82") #é
      output.gsub!(/\xE8/,"\x7A") #è
      output.gsub!(/\xFA/,"\xA3") #ú
      output.gsub!(/\xF9/,"\x97") #ù
      output.gsub!(/\xC9/,"\x90") #É

      logger.info "\n-------INVOICE #{ order.id } -------\n#{output}\n---------------\n"

      return output
    end





    def generate_escpos_items(order, type)
      overall_output = ''

      #Order.find_all_by_finished(false).each do |order|
        per_order_output = ''
        per_order_output +=
        "\e@"     +  # Initialize Printer
        "\e!\x38" +  # doube tall, double wide, bold

        "%-14.14s #%5i\n%-12.12s %8s\n" % [l(Time.now, :format => :time_short), order.id, @current_user.login, order.table.abbreviation] +

        per_order_output += "=====================\n"

        printed_items_in_this_order = 0
        order.items.each do |i|

          i.update_attribute :printed_count, i.count if i.count < i.printed_count

          next if i.count == i.printed_count

          next if (type == :drink and i.category.food) or (type == :food and !i.category.food)

          usage = i.quantity ? i.quantity.usage : i.article.usage
          next if (type == :takeaway and usage != 'b') or (type != :takeaway and usage == 'b')

          printed_items_in_this_order =+ 1

          per_order_output += "%i %-18.18s\n" % [ i.count - i.printed_count, i.article.name]
          per_order_output += "  %-18.18s\n" % ["#{i.quantity.prefix} #{ i.quantity.postfix}"] if i.quantity
          per_order_output += "! %-18.18s\n" % [i.comment] if i.comment and not i.comment.empty?

          i.options.each { |o| per_order_output += "* %-18.18s\n" % [o.name] }

          i.update_attribute :printed_count, i.count

          #per_order_output += "---------------------\n"
        end

        per_order_output +=
        "\n\n\n\n" +
        "\x1DV\x00" # paper cut at the end of each order/table
        overall_output += per_order_output if printed_items_in_this_order != 0
      #end

      overall_output = Iconv.conv('ISO-8859-15','UTF-8',overall_output)
      overall_output.gsub!(/\xE4/,"\x84") #ä
      overall_output.gsub!(/\xFC/,"\x81") #ü
      overall_output.gsub!(/\xF6/,"\x94") #ö
      overall_output.gsub!(/\xC4/,"\x8E") #Ä
      overall_output.gsub!(/\xDC/,"\x9A") #Ü
      overall_output.gsub!(/\xD6/,"\x99") #Ö
      overall_output.gsub!(/\xDF/,"\xE1") #ß
      overall_output.gsub!(/\xE9/,"\x82") #é
      overall_output.gsub!(/\xE8/,"\x7A") #è
      overall_output.gsub!(/\xFA/,"\xA3") #ú
      overall_output.gsub!(/\xF9/,"\x97") #ù
      overall_output.gsub!(/\xC9/,"\x90") #É

      logger.info "\n-------BON #{ type } -------\n#{overall_output}\n---------------\n"

      return overall_output
    end



    def generate_escpos_test
      out = "\e@" # Initialize Printer
      0.upto(255) { |i|
        out += i.to_s + i.chr
      }
      return out
    end
end
