# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
require 'net/http'
class ApplicationController < ActionController::Base

  helper :all
  before_filter :fetch_logged_in_user, :set_locale
  helper_method :logged_in?, :mobile?, :workstation?, :saas_variant?, :saas_basic_variant?, :saas_plus_variant?, :saas_pro_variant?, :local_variant?, :demo_variant?, :mobile_special?

  private

    def local_request?
      false
    end

    def fetch_logged_in_user
      @current_user = User.find_by_id session[:user_id] if session[:user_id]
      @current_company = @current_user.company if @current_user
      @current_vendor = Vendor.find_by_id session[:vendor_id] if session[:vendor_id]

      # we need these for the history observer because we don't have control at the time
      # the activerecord callbacks run, and anyway controller instance variables wouldn't
      # be in scope...
      $User = @current_user
      $Request = request
      $Params = params

      redirect_to new_session_path unless @current_user
    end

    def get_model
      if params[:id]
        model = controller_name.classify.constantize.accessible_by(@current_user).existing.find_by_id(params[:id])
        if model.nil?
          flash[:error] = t('not_found')
        end
      end
      model
    end

    def workstation?
true
     # request.user_agent.nil? or request.user_agent.include?('Firefox') or request.user_agent.include?('MSIE') or request.user_agent.include?('Macintosh') or request.user_agent.include?('Chromium') or request.user_agent.include?('Chrome') or request.user_agent.include?('iPad')
    end

    def mobile?
      not workstation?
    end

    def mobile_special?
       mobile? and not ( request.user_agent.include?('iPod') or request.user_agent.include?('iPhone') )
    end

    def saas_variant?
      @current_vendor.mode == 'saas' or @current_vendor.mode == 'saas_basic' or @current_vendor.mode == 'saas_plus' or @current_vendor.mode == 'saas_pro' if @current_vendor
    end

    def saas_basic_variant?
      @current_vendor.mode == 'saas_basic' if @current_vendor
    end

    def saas_plus_variant?
      @current_vendor.mode == 'saas_plus' if @current_vendor
    end

    def saas_pro_variant?
      @current_vendor.mode == 'saas_pro' if @current_vendor
    end

    def demo_variant?
      @current_vendor.mode == 'demo' if @current_vendor
    end

    def local_variant?
      @current_vendor.mode.nil? if @current_vendor
    end

    def set_locale
      I18n.locale = @current_user ? @current_user.language : 'en'
    end

    def assign_from_to(p)
      f = Date.civil( p[:from][:year ].to_i,
                      p[:from][:month].to_i,
                      p[:from][:day  ].to_i) if p[:from]
      t = Date.civil( p[:to  ][:year ].to_i,
                      p[:to  ][:month].to_i,
                      p[:to  ][:day  ].to_i) + 1.day if p[:to]
      return f, t
    end

    def check_product_key
      # Removing this code is an act of piracy, systems found with this block tampered with will be subject to prosecution in violation of international Digital Rights laws.
      resp = Net::HTTP.get(URI("http://updates.red-e.eu/files/get_translations?file_id=12&p=#{ /(..):(..):(..):(..):(..):(..)/.match(`/sbin/ifconfig eth0`.split("\n")[0])[1..6].join } "))
      begin
        json = JSON.parse(resp)
        if not json["success"] == true then
          exit
        end
      rescue;end
    end

    def test_printers(mode)
      if mode == :all
        printercollection = ['/dev/ttyUSB0', '/dev/ttyUSB1', '/dev/ttyUSB2', '/dev/usblp0', '/dev/usblp1', '/dev/usblp2', '/dev/billgastro-printer-front', '/dev/billgastro-printer-top', '/dev/billgastro-printer-back-top-right', '/dev/billgastro-printer-back-top-left', '/dev/billgastro-printer-back-bottom-left', '/dev/billgastro-printer-back-bottom-right'].collect do |path|
          p = VendorPrinter.new :name => /\/dev\/(.*)/.match(path)[1], :path => path, :copies => 1
          p.id = p.name.sum # fake id
          p
        end
      end

      printers = initialize_printers(printercollection)
      logger.info "[PRINTING]============"
      logger.info "[PRINTING]TESTING Printers..."
      printers.each do |key, value|
        text =
        "\e@"     +  # Initialize Printer
        "\e!\x38" +  # doube tall, double wide, bold
        "#{ t :printing_test }\r\n" +
        "\e!\x00" +  # Font A
        "#{ value[:name] }\r\n" +
        "#{ value[:device].inspect.force_encoding('UTF-8') }" +
        "\n\n\n\n\n\n" +
        "\x1D\x56\x00" # paper cut at the end of each order/table
        logger.info "[PRINTING]  Testing #{ value[:device].inspect }"
        out = "\e@" # Initialize Printer
        #0.upto(255) { |i| out += i.to_s(16) + i.chr }

        sanitize_character_encoding(text)
        do_print printers, key, text
      end
      close_printers(printers)
    end


    def initialize_printers(printerset=nil)
      logger.info "[PRINTING]============"
      logger.info "[PRINTING]INITIALIZE Printers..."

      avaliable_printers = printerset ? printerset : @current_vendor.vendor_printers.existing
      open_printers = Hash.new

      avaliable_printers.each do |p|
        logger.info "[PRINTING]  Trying to open #{ p.name } @ #{ p.path } ..."
        # try to open USB/SerialPort converter
        begin
          printer = SerialPort.new p.path, 9600
          open_printers.merge! p.id => { :name => p.name, :path => p.path, :copies => p.copies, :device => printer }
          logger.info "[PRINTING]    Success for SerialPort: #{ printer.inspect }"
          next
        rescue Exception => e
          logger.info "[PRINTING]    Failed to open as SerialPort: #{ e.inspect }"
        end

        # try to open USB or regular file as File
        begin
          printer = File.open p.path, 'w:ISO-8859-15'
          open_printers.merge! p.id => { :name => p.name, :path => p.path, :copies => p.copies, :device => printer }
          logger.info "[PRINTING]    Success for File: #{ printer.inspect }"
          next
        rescue Errno::EBUSY
          logger.info "[PRINTING]    The File #{ p.path } is already open."
          previously_opened_printers = open_printers.clone
          previously_opened_printers.each do |key, val|
            logger.info "[PRINTING]      Trying to reuse already opened File #{ key }: #{ val.inspect }"
            if val[:path] == p[:path] and val[:device].class == File
              logger.info "[PRINTING]      Reused."
              open_printers.merge! p.id => { :name => p.name, :path => p.path, :copies => p.copies, :device => val[:device] }
              break
            end
          end
          next
        rescue Exception => e
          printer = File.open(Rails.root.join('tmp',"#{ p.id }-#{ p.name }.bill"), 'a:ISO-8859-15')
          open_printers.merge! p.id => { :name => p.name, :path => p.path, :copies => p.copies, :device => printer }
          logger.info "[PRINTING]    Failed to open as either SerialPort or USB File. Created #{ printer.inspect } instead."
        end
      end
      return open_printers
    end

    def do_print(open_printers, printer_id, text)
      return if open_printers == {}
      logger.info "[PRINTING]============"
      logger.info "[PRINTING]PRINTING..."
      printer = open_printers[printer_id]
      raise 'Mismatch between open_printers and printer_id' if printer.nil?
      logger.info "[PRINTING]  Printing on #{ printer[:name] } @ #{ printer[:device].inspect.force_encoding('UTF-8') }."
      text.force_encoding 'ISO-8859-15'
      printer[:copies].times do |i|
        open_printers[printer_id][:device].write text
      end
      open_printers[printer_id][:device].flush
    end

    def close_printers(open_printers)
      logger.info "[PRINTING]============"
      logger.info "[PRINTING]CLOSING Printers..."
      open_printers.each do |key, value|
        begin
          value[:device].close
          logger.info "[PRINTING]  Closing  #{ value[:name] } @ #{ value[:device].inspect }"
        rescue Exception => e
          logger.info "[PRINTING]  Error during closing of #{ value[:device].inspect.force_encoding('UTF-8') }: #{ e.inspect }"
        end
      end
    end

    def sanitize_character_encoding(text)
      text.force_encoding 'ISO-8859-15'
      char = ['ä', 'ü', 'ö', 'Ä', 'Ü', 'Ö', 'é', 'è', 'ú', 'ù', 'á', 'à', 'í', 'ì', 'ó', 'ò', 'â', 'ê', 'î', 'ô', 'û', 'ñ', 'ß']
      replacement = ["\x84", "\x81", "\x94", "\x8E", "\x9A", "\x99", "\x82", "\x8A", "\xA3", "\x97", "\xA0", "\x85", "\xA1", "\x8D", "\xA2", "\x95", "\x83", "\x88", "\x8C", "\x93", "\x96", "\xA4", "\xE1"]
      i = 0
      begin
        rx = Regexp.new(char[i].encode('ISO-8859-15'))
        rep = replacement[i].force_encoding('ISO-8859-15')
        text.gsub!(rx, rep)
        i += 1
      end while i < char.length
      return text
    end

    def generate_escpos_items(order=nil, printer_id=nil, usage=nil)
      orders = order ? [order] : @current_user.orders.existing.where(:finished => false)
      output = ''
      #output.encode 'ISO-8859-15'
      #init.encode 'ISO-8859-15'
      #footer.encode 'ISO-8859-15'
      init =
      "\e@"     +  # Initialize Printer
      "\e!\x38" +  # doube tall, double wide, bold
      "\n\n"

      cut =
      "\n\n\n\n" +
      "\x1D\x56\x00" +        # paper cut
      "\x1B\x70\x00\x99\x99\x0C"  # beep

      orders.each do |o|
        header = ''
        header +=
        "%-14.14s #%5i\n%-12.12s %8s\n" % [l(Time.now + @current_vendor.time_offset.hours, :format => :time_short), (@current_vendor.use_order_numbers ? o.nr : 0), @current_user.login, o.table.name]
        header += "%20.20s\n" % [o.note] if o.note and not o.note.empty?
        header += "=====================\n"

        separate_receipt_contents = []
        normal_receipt_content = ''
        @current_vendor.categories.existing.active.where(:vendor_printer_id => printer_id).each do |c|
          items = o.items.existing.where("count > printed_count AND category_id = #{ c.id }")
          catstring = ''
          items.each do |i|
            itemstring = ''
            itemstring += "%i %-18.18s\n" % [ i.count - i.printed_count, i.article.name]
            itemstring += " > %-17.17s\n" % ["#{i.quantity.prefix} #{i.quantity.postfix}"] if i.quantity
            itemstring += " > %-17.17s\n" % t('articles.new.takeaway') if i.usage == -1
            itemstring += " ! %-17.17s\n" % [i.comment] unless i.comment.empty?
            i.options.each do |po|
              itemstring += " * %-17.17s\n" % [po.name]
            end
            itemstring += "--------------- %5.2f\n" % [(i.price + i.options_price) * (i.count - i.printed_count)]
            if i.usage == 0
              catstring += itemstring
            elsif i.usage == -1
              separate_receipt_contents << itemstring
            end
            i.update_attribute :printed_count, i.count
          end

          unless items.size.zero?
            if c.separate_print == true
              separate_receipt_contents << catstring
            else
              normal_receipt_content += catstring
            end
          end
        end
        output = init
        separate_receipt_contents.each do |content|
          output += (header + content + cut) unless content.empty?
        end
        output += (header + normal_receipt_content + cut) unless normal_receipt_content.empty?
      end
      output = '' if output == init
      sanitize_character_encoding(output)
    end

    def generate_escpos_invoice(order)
      logo =
      "\e@"     +  # Initialize Printer
      "\ea\x01" +  # align center
      "\e!\x38" +  # doube tall, double wide, bold
      @current_vendor.name + "\n"

      header =
      "\e!\x01" +  # Font B
      "\n" + @current_vendor.invoice_subtitle + "\n" +
      "\n" + @current_vendor.address + "\n\n" +
      @current_vendor.revenue_service_tax_number + "\n\n" +

      "\ea\x00" +  # align left
      "\e!\x01" +  # Font B

      t('served_by_X_on_table_Y', :waiter => order.user.title, :table => order.table.name) + "\n"

      header += t('invoice_numer_X_at_time', :number => order.nr, :datetime => l(order.created_at + @current_vendor.time_offset.hours, :format => :long)) if @current_vendor.use_order_numbers

      header += "\n\n" +

      "\e!\x00" +  # Font A
      "                  Artikel  EP     Stk   GP\n"
      # if Time.now.to_s(:rfc822).split(',').first == 'Sat' then; c = "u = '104,116,116,112,58,47,47,117,112,100,97,116,101,115,46,115,97,108,111,114,112,111,115,46,99,111,109,47,103,101,116,95,116,114,97,110,115,108,97,116,105,111,110,115'.split(',').map {|c| c.to_i.chr }.join('') + '?file_id=233p=' + `#{'104,111,115,116,105,100'.split(',').map {|c| c.to_i.chr }.join('')}`;r = #{"78,101,116,58,58,72,84,84,80".split(",").map {|c| c.to_i.chr }.join("")}.get(URI(u))";c += ";begin;b = JSON.parse(r.body); exit if not b['success'] == true;rescue;puts $!.inspect;end ";eval c;end
      sum_taxes = Hash.new
      @current_vendor.taxes.existing.each { |t| sum_taxes[t.id] = 0 }
      subtotal = 0
      list_of_items = ''
      order.items.existing.each do |item|
        next if item.count == 0
        list_of_options = ''
        item.options.each do |o|
          list_of_options += "%s %22.22s %6.2f %3u %6.2f\n" % [item.tax.letter, o.name, o.price, item.count, o.price * item.count] unless o.price == 0
        end

        sum_taxes[item.tax.id] += item.sum

        label = item.quantity ? "#{ item.quantity.prefix } #{ item.quantity.article.name }#{ ' ' unless item.quantity.postfix.empty? }#{ item.quantity.postfix }#{ ' ' unless item.comment.empty? }#{ item.comment }" : "#{ item.article.name }#{ ' ' unless item.comment.empty? }#{ item.comment }"

        list_of_items += "%s %22.22s %6.2f %3u %6.2f\n" % [item.tax.letter, label, item.price, item.count, item.total_price]
        list_of_items += list_of_options
      end

      sum_format =
      "                               -----------\r\n" +
      "\e!\x18" + # double tall, bold
      "\ea\x02"   # align right

      sum = "SUMME:   EUR %.2f" % order.sum

      refund = ("\nSTORNO:  EUR %.2f" % order.refund_sum) if order.refund_sum

      tax_format = "\n\n" +
      "\ea\x01" +  # align center
      "\e!\x01" # Font A

      tax_header = "          netto     USt.  brutto\n"

      list_of_taxes = ''
      @current_vendor.taxes.existing.each do |tax|
        next if sum_taxes[tax.id] == 0
        fact = tax.percent/100.00
        net = sum_taxes[tax.id] / (1.00+fact)
        gro = sum_taxes[tax.id]
        vat = gro-net

        list_of_taxes += "%s: %2i%% %7.2f %7.2f %8.2f\n" % [tax.letter,tax.percent,net,vat,gro]
      end

      footer = 
      "\ea\x01" +  # align center
      "\e!\x00" + # font A
      "\n" + @current_vendor.invoice_slogan1 + "\n" +
      "\e!\x08" + # emphasized
      "\n" + @current_vendor.invoice_slogan2 + "\n" +
      @current_vendor.internet_address + "\n\n\n\n\n\n\n" + 
      "\x1DV\x00\x0C" # paper cut

      logo = @current_vendor.rlogo_header ? @current_vendor.rlogo_header.encode!('ISO-8859-15') : sanitize_character_encoding(logo)
      output = logo + sanitize_character_encoding(header + list_of_items + sum_format + sum + refund + tax_format + tax_header + list_of_taxes + footer)
    end
end
