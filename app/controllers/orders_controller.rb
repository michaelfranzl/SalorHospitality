class OrdersController < ApplicationController

  def index
    @tables = Table.all
    @last_finished_order = Order.find_all_by_finished(true).last
  end

  def show
    @client_data = File.exist?('client_data.yaml') ? YAML.load_file( 'client_data.yaml' ) : {}
    id = params[:id].to_i
    from = id - 1
    to = id + 1
    order_range = Order.find(:all, :conditions => { :id => from..to })
    @previous_order = order_range[0]
    @previous_order = @order if @previous_order.nil?
    @order = order_range[1]
    @next_order = order_range[2]
    @next_order = @order if @next_order.nil?
    respond_to do |wants|
      wants.html
      wants.bon {
        render :text => generate_escpos_invoice(@order)
      }
    end
  end

  def new
    @order = Order.new
    @categories = Category.find(:all, :order => :sort_order)
    @order.table_id = params[:table_id]
    @order.user = @current_user if ipod?
    @table = Table.find(@order.table_id)
    @active_cost_centers = CostCenter.find(:all, :conditions => { :active => 1 })
  end

  def edit
    @order = Order.find(params[:id])
    @categories = Category.find(:all, :order => :sort_order)
    @active_cost_centers = CostCenter.find(:all, :conditions => { :active => 1 })
    render :new
  end

  def create
    @order = Order.new(params[:order])
    session[:last_user_id] = @order.user_id
    @categories = Category.find(:all, :order => :sort_order)
    @active_cost_centers = CostCenter.find(:all, :conditions => { :active => 1 })
    @order.table_id = params[:table_id]
    @order.sum = calculate_order_sum @order
    order_action = params[:order_action]
    @order.save ? process_order(@order, order_action) : render(:new)
  end

  def update
    @order = Order.find(params[:id])
    @categories = Category.all
    @active_cost_centers = CostCenter.find(:all, :conditions => { :active => 1 })
    order_action = params[:order_action]
    if @order.update_attributes(params[:order])
      process_order(@order, order_action)
      @order.update_attribute( :sum, calculate_order_sum(@order) )
    else
      render(:new)
    end
  end

  def storno
    @order = Order.find(params[:id])
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
  
  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to orders_path
  end

  def items
    respond_to do |wants|
      wants.bon { render :text => generate_escpos_items(:drink) }
    end
  end




  private

    def reduce_stocks(order)
      order.items.each do |item|
        item.article.ingredients.each do |ingredient|
          ingredient.stock.balance -= item.count * ingredient.amount
          ingredient.stock.save
        end
      end
    end

    def process_order(order, order_action)
      order.items.each { |i| i.delete if i.count.zero? }
      order.delete and redirect_to orders_path and return if order.items.size.zero?

      case order_action
        when 'save_and_go_back'
          redirect_to orders_path
        when 'go_to_invoice'
          redirect_to table_path(order.table)
        when 'split_invoice_all_at_once'
          items_for_split_invoice = Item.find(:all, :conditions => { :order_id => order.id, :partial_order => true })
          make_split_invoice(order, items_for_split_invoice, :all_at_once)
          redirect_to table_path(order.table)
        when 'split_invoice_one_at_a_time'
          items_for_split_invoice = Item.find(:all, :conditions => { :order_id => order.id, :partial_order => true })
          make_split_invoice(order, items_for_split_invoice, :one_at_a_time)
          redirect_to table_path(order.table)
        when /print/ # number after print determines directly the serial port 0..3
          @order.update_attribute(:finished, true) and reduce_stocks @order
          unfinished_orders_on_same_table = Order.find(:all, :conditions => { :table_id => order.table, :finished => false })
          unfinished_orders_on_same_table.empty? ? redirect_to(orders_path) : redirect_to(table_path(order.table))
          File.open('order.escpos', 'w') { |f| f.write(generate_escpos_invoice(order)) }
          `cat order.escpos > out#{ /print(.)/.match(order_action)[1] }.escpos`
        when 'storno'
          items_for_storno = Item.find(:all, :conditions => { :order_id => order.id, :storno_status => 1 })
          make_storno(order, items_for_storno)
          redirect_to "/orders/storno/#{order.id}"
      end

      File.open('bar.escpos', 'w') { |f| f.write(generate_escpos_items(:drink)) }
      `cat bar.escpos > out-bar.escpos`

      File.open('kitchen.escpos', 'w') { |f| f.write(generate_escpos_items(:food)) }
      `cat kitchen.escpos > out-kitchen.escpos`
    end


    def make_split_invoice(parent_order, split_items, mode)
      return if split_items.empty?
      if parent_order.order # if there already exists one child order, use it for the split invoice
        split_invoice = parent_order.order
      else # create a brand new split invoice, and make it belong to the parent order
        split_invoice = parent_order.clone
        split_invoice.save
        parent_order.order = split_invoice
      end
      case mode
        when :all_at_once
          split_items.each do |i|
            i.update_attribute :order_id, split_invoice.id # move item to the new order
            i.update_attribute :partial_order, false # after the item has moved to the new order, leave it alone
          end
        when :one_at_a_time
          old = split_items[0] # in this mode there will only single items to split
          new = old.clone
          new.order = split_invoice
          new.count += 1
          old.count -= 1
          old.delete if old.count == 0
          new.partial_order = old.partial_order = false
          new.save
          old.save
      end
      parent_order = Order.find(params[:id]) # re-read
      parent_order.delete if  parent_order.items.empty?
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
      client_data = File.exist?('client_data.yaml') ? YAML.load_file( 'client_data.yaml' ) : {}

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
        label = item.quantity_id ? "#{ item.quantity.article.name} #{ item.quantity.name}" : item.article.name
        label = Iconv.conv('ISO-8859-15//TRANSLIT','UTF-8',label)
        list_of_items += "%c %20.20s %7.2f %3u %7.2f\n" % [tax_id+64,label,p,item.count,sum]
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
      "\e!\x88" + # underline, emphasized
      client_data[:internet] + "\n\n\n\n\n\n\n" + 
      "\x1DV\x00" # paper cut

      output = header + list_of_items + sum + tax_header + list_of_taxes + footer
      #output = Iconv.conv('ISO-8859-15','UTF-8',output)
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
      return output
    end





    def generate_escpos_items(type)
      output = ''
      Order.find_all_by_finished(false).each do |order|
        output +=
        "\e@"     +  # Initialize Printer

        "\e!\x00" +  # Font A
        "\e!\x08" +  # Font A, emphasized
        "%-25.25s %15s\n" % [order.user.title, order.table.name] +
        "===========================\n\n\n"

        printed_items = 0
        order.items.each do |i|
          next if i.count == i.printed_count or (i.category.food and type == :drink) or (!i.category.food and type == :food) # no need to print
          printed_items =+ 1

          quantityname = i.quantity ? i.quantity.name : ''
          output +=
          "\e!\x38" +  # doube tall, double wide, bold
          "%u %-17.17s\n" % [i.count - i.printed_count, i.article.name] +
          "  %-17.17s\n" % [quantityname] +
          "  * %-15.15s\n" % [i.comment]

          i.options.each { |o| output += "  - %-15.15s\n" % [o.name] }

          output += "---------------------------\n\n\n"

          i.update_attribute :printed_count, i.count
        end

        output +=
        "\n\n\n\n\n\n" +
        "\x1DV\x00" # paper cut at the end of each order/table
        output = '' if printed_items == 0
      end

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
      return output
    end



    def generate_escpos_test(order)
      out =
      "\e@"     +  # Initialize Printer
      "\ea\x02"
      0.upto(255) { |i|
        out += "\et%c %i\xDC\n" % [i,i]
      }
      return out
    end
end
