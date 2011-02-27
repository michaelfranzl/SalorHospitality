class ItemsController < ApplicationController

  def index
    respond_to do |wants|
      wants.bon { render :text => generate_escpos_items(:drink) }
    end
  end

  def update
    @item_to_split = Item.find_by_id(params[:id]) # find item on which was clicked
    @order = @item_to_split.order
    @cost_centers = CostCenter.find_all_by_active(true)
    make_split_invoice(@order, @item_to_split)
    @orders = Order.find_all_by_finished(false, :conditions => { :table_id => @order.table_id })
    render 'split_invoice'
  end

  private

    def make_split_invoice(parent_order, split_item)

      return if split_item.nil?

      if parent_order.order # if there already exists one child order, use it for the split invoice
        split_invoice = parent_order.order
      else # create a brand new split invoice, and make it belong to the parent order
        split_invoice = parent_order.clone
        split_invoice.nr = get_next_unique_and_reused_order_number
        split_invoice.save
        parent_order.order = split_invoice  # make an association between parent and child
        split_invoice.order = parent_order  # ... and vice versa
      end

      parent_item = split_item
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

      parent_order = Order.find(parent_order.id) # re-read

      if parent_order.items.empty?
        MyGlobals::unused_order_numbers << parent_order.nr
        parent_order.delete
      end

      parent_order.update_attribute( :sum, calculate_order_sum(parent_order) ) if not parent_order.items.empty?
      split_invoice.update_attribute( :sum, calculate_order_sum(split_invoice) )
    end

    def generate_escpos_test
      out = "\e@" # Initialize Printer
      0.upto(255) { |i|
        out += i.to_s + i.chr
      }
      return out
    end

    def generate_escpos_invoice(order)
      client_data = File.exist?('config/client_data.yaml') ? YAML.load_file( 'config/client_data.yaml' ) : { :name => '', :subtitle => '', :address => '', :taxnumber => '', :slogan1 => '', :slogan2 => '', :internet => '' }

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
      t('invoice_numer_X_at_time', :number => order.nr, :datetime => l(order.created_at, :format => :long)) + "\n\n" +

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
      output.gsub!(/\x00E4/,"\x84") #ä
      output.gsub!(/\x00FC/,"\x81") #ü
      output.gsub!(/\x00F6/,"\x94") #ö
      output.gsub!(/\x00C4/,"\x8E") #Ä
      output.gsub!(/\x00DC/,"\x9A") #Ü
      output.gsub!(/\x00D6/,"\x99") #Ö
      output.gsub!(/\x00DF/,"\xE1") #ß
      output.gsub!(/\x00E9/,"\x82") #é
      output.gsub!(/\x00E8/,"\x7A") #è
      output.gsub!(/\x00FA/,"\xA3") #ú
      output.gsub!(/\x00F9/,"\x97") #ù
      output.gsub!(/\x00C9/,"\x90") #É
      return output
    end

end
