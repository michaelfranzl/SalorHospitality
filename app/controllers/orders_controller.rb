class OrdersController < ApplicationController

  def index
    @tables = Table.all
  end

  def show
    @order = Order.find(params[:id])
    respond_to do |wants|
      wants.html
      wants.bon {
        render :text => generate_escpos_invoice(@order)
        #render :text => generate_escpos_test(@order)
      }
    end
  end

  def new
    @order = Order.new
    @categories = Category.find(:all, :order => :sort_order)
    @order.table_id = params[:table_id]
    @order.user_id = session[:last_user_id]
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
    redirect_to orders_path and return if @order.items.size.zero?
    @order.finished = params.has_key?('finish_order') ? true : false
    @order.save ? process_order(@order) : render(:new)
  end

  def update
    @order = Order.find(params[:id])
    @categories = Category.all
    @active_cost_centers = CostCenter.find(:all, :conditions => { :active => 1 })
    @order.update_attribute( :sum, calculate_order_sum(@order) )
    params['order']['items_attributes'].each do |item|
      item[1]['_delete'] = 1 if item[1]['count'] == '0' or item[1]['article_id'] == ''
    end
    @order.finished = true if params.has_key?('finish_order')
    @order.update_attributes(params[:order]) ? process_order(@order) : render(:new)
  end

  def destroy
    @order = Order.find(params[:id])
    flash[:notice] = "Die Bestellung \"#{ @order.name }\" wurde erfolgreich geloescht."
    @order.destroy
    redirect_to table_orders_path
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

    def make_partial_order(order, items_for_partial_order)
      partial_order = order.clone
      partial_order.finished = false
      if partial_order.save
        items_for_partial_order.each do |item|
          item.update_attribute :order_id, partial_order.id
        end
      else
        flash[:error] = 'Partial Order could not be saved.'
      end
      Item.update_all :partial_order => false
      partial_order
    end

    def process_order(order)
      items_for_partial_order = Item.find_all_by_partial_order(true)
      partial_order = make_partial_order(order, items_for_partial_order) if !items_for_partial_order.empty?
      if order.finished
        reduce_stocks order
        redirect_to order_path order
      else
        partial_order ? redirect_to(edit_order_path(partial_order)) : redirect_to(orders_path)
      end
    end

    def calculate_order_sum(order)
      subtotal = 0
      order.items.each do |item|
        next if !item.id
        c = item.count
        p = item.article.price
        if !item.free
          sum = c * p
          subtotal += c * p
        end
      end
      return subtotal
    end

    
    def generate_escpos_invoice(order)
      header =
      "\e@"     +  # Initialize Printer
      "\ea\x01" +  # align center

      "\e!\x38" +  # doube tall, double wide, bold
      t("clients.#{MyGlobals.client}.invoice_title") + "\n" +

      "\e!\x01" +  # Font B
      "\n" + t("clients.#{MyGlobals.client}.invoice_subtitle") + "\n\n" +
      "\n" + t("clients.#{MyGlobals.client}.address") + "\n\n" +
      t("clients.#{MyGlobals.client}.tax_number") + "\n\n" +

      "\ea\x00" +  # align left
      "\e!\x01" +  # Font B
      "#{ t :served_by } #{ order.user.title } auf Tisch Nr. #{ order.table.id }\n" +
      "Bestellung Nr. #{order.id} am #{l order.created_at, :format => :long}\n\n" +

      "\e!\x00" +  # Font A
      "               Artikel    EP    Stk   GP\n"

      sum_taxes = Array.new(Tax.count, 0)
      subtotal = 0
      list_of_items = ''
      order.items.each do |item|
        c = item.count
        p = item.article.price
        sum = 0
        if !item.free
          sum = c * p
          subtotal += sum
        end
        tax_id = item.article.category.tax.id
        sum_taxes[tax_id-1] += sum
        itemname = Iconv.conv('ISO-8859-15','UTF-8',item.article.name)
        list_of_items += "%c %20.20s %7.2f %3u %7.2f\n" % [tax_id+64,itemname,p,c,sum]
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
        next if sum_taxes[tax_id]==0
        fact = tax.percent/100.00
        net = sum_taxes[tax_id]/(1.00+fact)
        gro = sum_taxes[tax_id]
        vat = gro-net

        list_of_taxes += "%c: %2i%% %7.2f %7.2f %8.2f\n" % [tax.id+64,tax.percent,net,vat,gro]
      end

      footer = 
      "\ea\x01" +  # align center
      "\e!\x00" + # font A
      "\n" + t("clients.#{MyGlobals.client}.invoice_subtitle1") + "\n" +
      "\e!\x08" + # emphasized
      "\n" + t("clients.#{MyGlobals.client}.invoice_subtitle2") + "\n" +
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
