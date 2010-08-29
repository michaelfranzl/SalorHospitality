class OrdersController < ApplicationController

  def index
    @tables = Table.all
    @last_finished_order = Order.find_all_by_finished(true).last
  end

  def show
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
    @order.user_id = session[:last_user_id]
    @table = Table.find(@order.table_id)
    @username = @order.user_id ? User.find(@order.user_id) : ''
    @active_cost_centers = CostCenter.find(:all, :conditions => { :active => 1 })
  end

  def edit
    @order = Order.find(params[:id])
    @categories = Category.find(:all, :order => :sort_order)
    @active_cost_centers = CostCenter.find(:all, :conditions => { :active => 1 })
    render :new
  end

  def create
    debugger
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
      order.items.each do |item|
        item.delete if item.count.zero?
      end
      order.delete and redirect_to orders_path and return if order.items.size.zero?
      items_for_partial_order = Item.find(:all, :conditions => { :order_id => order.id, :partial_order => true })
      items_for_storno = Item.find(:all, :conditions => { :order_id => order.id, :storno_status => 1 })
      make_partial_order(order, items_for_partial_order) if !items_for_partial_order.empty?
      make_storno(order, items_for_storno) if !items_for_storno.empty?

      case order_action
        when 'save_and_go_back'
          redirect_to orders_path
        when 'go_to_invoice', 'split'
          redirect_to table_path(order.table)
        when 'print'
          @order.update_attribute(:finished, true) and reduce_stocks @order
          redirect_to "#{order_path(order)}.bon"
        when 'storno'
          redirect_to "/orders/storno/#{order.id}"
      end
    end

    def make_partial_order(order, items_for_partial_order)
      partial_order = order.clone
      if partial_order.save
        items_for_partial_order.each do |item|
          item.update_attribute :order_id, partial_order.id
          item.update_attribute :partial_order, false
          item.update_attribute :cost_center_id, params[:cost_center_id]
        end
        order = Order.find(params[:id])
        order.delete if order.items.empty?
      else
        flash[:error] = 'Partial Order could not be saved.'
      end
      return partial_order
    end
    
    # storno_status: 1 = marked for storno, 2 = is storno clone, 3 = storno original
    #
    def make_storno(order, items_for_storno)
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
        c = item.count
        p = item.quantity_id ? item.quantity.price : item.article.price
        sum = c * p
        subtotal += c * p
      end
      return subtotal
    end

    
    def generate_escpos_invoice(order)
    
      invoice_title = t("clients.#{MyGlobals.client}.invoice_title")
      invoice_title = Iconv.conv('ISO-8859-15//TRANSLIT','UTF-8',invoice_title)    
    
    
      invoice_subtitle = t("clients.#{MyGlobals.client}.invoice_subtitle")
      invoice_subtitle = Iconv.conv('ISO-8859-15//TRANSLIT','UTF-8',invoice_subtitle)
      
      invoice_address = t("clients.#{MyGlobals.client}.address")
      invoice_address = Iconv.conv('ISO-8859-15//TRANSLIT','UTF-8',invoice_address)
      
      invoice_subtitle1 = t("clients.#{MyGlobals.client}.invoice_subtitle1")
      invoice_subtitle1 = Iconv.conv('ISO-8859-15//TRANSLIT','UTF-8',invoice_subtitle1)

      invoice_subtitle2 = t("clients.#{MyGlobals.client}.invoice_subtitle2")
      invoice_subtitle2 = Iconv.conv('ISO-8859-15//TRANSLIT','UTF-8',invoice_subtitle2)
      
      header =
      "\e@"     +  # Initialize Printer
      "\ea\x01" +  # align center

      "\e!\x38" +  # doube tall, double wide, bold
      invoice_title + "\n" +

      "\e!\x01" +  # Font B
      "\n" + invoice_subtitle + "\n\n" +
      "\n" + invoice_address + "\n\n" +
      t("clients.#{MyGlobals.client}.tax_number") + "\n\n" +

      "\ea\x00" +  # align left
      "\e!\x01" +  # Font B
      "#{ t :served_by } #{ order.user.title } auf #{ order.table.name }\n" +
      "Bestellung Nr. #{order.id} am #{l order.created_at, :format => :long}\n\n" +

      "\e!\x00" +  # Font A
      "               Artikel    EP    Stk   GP\n"

      sum_taxes = Array.new(Tax.count, 0)
      subtotal = 0
      list_of_items = ''
      order.items.each do |item|
        c = item.count
        p = item.quantity_id ? item.quantity.price : item.article.price
        p = -p if item.storno_status == 2
        sum = 0
        sum = c * p
        subtotal += sum
        tax_id = item.article.category.tax.id
        sum_taxes[tax_id-1] += sum
        label = item.quantity_id ? "#{ item.quantity.article.name} #{ item.quantity.name}" : item.article.name
        label = Iconv.conv('ISO-8859-15//TRANSLIT','UTF-8',label)
        list_of_items += "%c %20.20s %7.2f %3u %7.2f\n" % [tax_id+64,label,p,c,sum]
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
      "\n" + invoice_subtitle1 + "\n" +
      "\e!\x08" + # emphasized
      "\n" + invoice_subtitle2 + "\n" +
      "\e!\x88" + # underline, emphasized
      t("clients.#{MyGlobals.client}.website") + "\n\n\n\n\n\n\n" + 
      "\x1DV\x00" # paper cut

      output = header + list_of_items + sum + tax_header + list_of_taxes + footer

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
