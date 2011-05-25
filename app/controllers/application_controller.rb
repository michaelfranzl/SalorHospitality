# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class ApplicationController < ActionController::Base

  helper :all
  before_filter :fetch_logged_in_user, :select_current_company, :set_locale
  helper_method :logged_in?, :mobile?, :workstation?, :saas_variant?, :local_variant?, :test_printers

  private

    def local_request?
      false
    end

    def fetch_logged_in_user
      @current_user = User.find(session[:user_id]) if session[:user_id]
      redirect_to '/' if @current_user.nil?
    end

    def select_current_company
      if @current_user
        @current_company = @current_user.company
        if not @current_company
          @current_company = Company.create
          @current_user.company = @current_company
          @current_user.save
        end
      end
    end

    def logged_in?
      ! @current_user.nil?
    end

    def workstation?
       request.user_agent.include?('Firefox') or request.user_agent.include?('MSIE') or request.user_agent.include?('Macintosh')
    end

    def mobile?
      not workstation?
    end

    def saas_variant?
      @current_company.saas if @current_company
    end

    def local_variant?
      not saas_variant?
    end

    def set_locale
      I18n.locale = @current_user ? @current_user.language : 'en'
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

    def get_next_unique_and_reused_order_number
      if not @current_company.unused_order_numbers.empty?
        # reuse order numbers if present
        nr = @current_company.unused_order_numbers.first
        @current_company.unused_order_numbers.delete(nr)
        @current_company.save
      elsif not @current_company.largest_order_number.zero?
        # increment largest order number
        nr = @current_company.largest_order_number + 1
        @current_company.update_attribute :largest_order_number, nr
      else
        # find Order with largest nr attribute from database. this should happen only once per application instance.
        last_order = Order.first(:order => 'nr DESC')
        nr = last_order ? last_order.nr + 1 : 1
      end
      return nr
    end

    def test_printers
      printers = initialize_printers
      logger.info "[PRINTING]============"
      logger.info "[PRINTING]TESTING Printers..."
      printers.each do |key, value|
        text =
        "\e@"     +  # Initialize Printer
        "\e!\x38" +  # doube tall, double wide, bold
        "Bill Gastro\r\n#{ value[:name] }\r\n" +
        "\e!\x00" +  # Font A
        "#{ value[:device].inspect }" +
        "\n\n\n\n\n\n" +
        "\x1DV\x00" # paper cut at the end of each order/table
        logger.info "[PRINTING]  Testing #{ value[:device].inspect }"
        print printers, key, text
        #print printers, key, generate_escpos_test
      end
    end

    def generate_escpos_test
      out = "\e@" # Initialize Printer
      0.upto(255) { |i|
        out += i.to_s(16) + ' ' + i.chr
      }
      return out
    end

    def initialize_printers
      logger.info "[PRINTING]============"
      logger.info "[PRINTING]INITIALIZE Printers..."

      avaliable_printers = @current_company.vendor_printers
      open_printers = Hash.new

      avaliable_printers.each do |p|
        logger.info "[PRINTING]  Trying to open #{ p.name } @ #{ p.path } ..."
        # try to open USB/SerialPort converter
        begin
          printer = SerialPort.new p.path, 9600
          open_printers.merge! p.id => { :name => p.name, :path => p.path, :device => printer }
          logger.info "[PRINTING]    Success for SerialPort: #{ printer.inspect }"
          next
        rescue Exception => e
          logger.info "[PRINTING]    Failed to open as SerialPort: #{ e.inspect }"
        end

        # try to open USB or regular file as File
        begin
          printer = File.open p.path, 'w:ASCII-8BIT'
          open_printers.merge! p.id => { :name => p.name, :path => p.path, :device => printer }
          logger.info "[PRINTING]    Success for File: #{ printer.inspect }"
          next
        rescue Errno::EBUSY
          logger.info "[PRINTING]    The File #{ p.path } is already open."
          previously_opened_printers = open_printers.clone
          previously_opened_printers.each do |key, val|
            logger.info "[PRINTING]      Trying to reuse previously open printer id #{ key }: #{ val.inspect }"
            if val[:path] == p[:path] and val[:device].class == File
              logger.info "[PRINTING]      Reused."
              open_printers.merge! p.id => { :name => p.name, :path => p.path, :device => val[:device] }
              break
            end
          end
          next
        rescue Exception => e
          printer = File.open(Rails.root.join('tmp',"#{p.id}-#{p.name}.bill"), 'a:ASCII-8BIT')
          open_printers.merge! p.id => { :name => p.name, :path => p.path, :device => printer }
          logger.info "[PRINTING]    Failed to open as either SerialPort or USB File. Created #{ printer.inspect } instead."
        end
      end
      return open_printers
    end

    def print(open_printers, printer_id, text)
      logger.info "[PRINTING]============"
      logger.info "[PRINTING]PRINTING..."
      printer = open_printers[printer_id]
      logger.info "[PRINTING]  Printing on #{ printer[:name] } @ #{ printer[:path] }: #{ printer[:device] }"

      text.force_encoding 'ASCII-8BIT'

      sanitize_tokens = [/ä/,"\x84",/ü/,"\x81",/ö/,"\x94",/Ä/,"\x8E",/Ü/,"\x9A",/Ö/,"\x99",/ß/,"\xE1",/é/,"\x82",/è/,"\x8A",/ú/,"\xA3",/ù/,"\x97",/á/,"\xA0",/à/,"\x85",/í/,"\xA1",/ì/,"\x8D",/ó/,"\xA2",/ò/,"\x95",/â/,"\x83",/ê/,"\x88",/î/,"\x8C",/ô/,"\x93",/û/,"\x96",/ñ/,"\xA4"]

      begin
        i = 0
        begin
          text.gsub!(sanitize_tokens[i], sanitize_tokens[i+1])
          i += 2
        end while i < sanitize_tokens.length
      rescue Exception => e
        logger.info "[PRINTING] Error in sanitize: #{ e.inspect }"
      end

      open_printers[printer_id][:device].write text
      open_printers[printer_id][:device].flush
    end

    def close_printers(open_printers)
      logger.info "[PRINTING]============"
      logger.info "[PRINTING]CLOSING Printers..."
      open_printers.each do |key, value|
        begin
          value[:device].close
debugger
          logger.info "[PRINTING]  Closing #{ value.inspect }"
        rescue Exception => e
          logger.info "[PRINTING]  Error during closing of #{ value.inspect }: #{ e.inspect }"
        end
      end
    end

    def generate_escpos_items(order, printer_id, usage)
      orders = order ? [order] : Order.find_all_by_finished(false)
      overall_output = ''
      orders.each do |o|
        per_order_output = ''
        header =
        "\e@"     +  # Initialize Printer
        "\e!\x38"    # doube tall, double wide, bold

        per_order_output +=
        "%-14.14s #%5i\n%-12.12s %8s\n" % [l(Time.now, :format => :time_short), o.nr, @current_user.login, o.table.abbreviation] +

        per_order_output += "=====================\n"

        printed_items_in_this_order = 0
        o.items.each do |i|
          i.update_attribute :printed_count, i.count if i.count < i.printed_count
          next if i.count == i.printed_count or i.count == 0

          item_usage = i.quantity ? i.quantity.usage : i.article.usage

          next if (i.count <= i.printed_count)          or
                  (printer_id != i.category.vendor_printer_id) or
                  (usage != item_usage)

          printed_items_in_this_order += 1

          per_order_output += "%i %-17.17s\n" % [ i.count - i.printed_count, i.article.name]
          per_order_output += " > %-17.17s\n" % ["#{i.quantity.prefix} #{ i.quantity.postfix}"] if i.quantity
          per_order_output += " ! %-17.17s\n" % [i.comment] if i.comment and not i.comment.empty?

          i.printoptions.each do |po|
            per_order_output += " * %-17.17s\n" % [po.name]
            i.options << po
          end

          i.printoptions = []
          i.printed_count = i.count 
          i.save
        end

        footer =
        "\n\n\n\n" +
        "\x1DV\x00" + # paper cut at the end of each order/table
        "\x16\x20105"

        overall_output += header + per_order_output + footer if printed_items_in_this_order != 0
      end

      overall_output
    end

    def generate_escpos_test
      out = "\e@" # Initialize Printer
      0.upto(255) { |i|
        out += i.to_s + i.chr
      }
      return out
    end

    def generate_escpos_invoice(order)
      header =
      "\e@"     +  # Initialize Printer
      "\ea\x01" +  # align center

      "\e!\x38" +  # doube tall, double wide, bold
      @current_company.name + "\n" +

      "\e!\x01" +  # Font B
      "\n" + @current_company.invoice_subtitle + "\n" +
      "\n" + @current_company.address + "\n\n" +
      @current_company.revenue_service_tax_number + "\n\n" +

      "\ea\x00" +  # align left
      "\e!\x01" +  # Font B
      t('served_by_X_on_table_Y', :waiter => order.user.title, :table => order.table.name) + "\n" +
      t('invoice_numer_X_at_time', :number => order.nr, :datetime => l(order.created_at, :format => :long)) + "\n\n" +

      "\e!\x00" +  # Font A
      "               Artikel    EP    Stk   GP\n"

      sum_taxes = Hash.new
      Tax.all.each { |t| sum_taxes[t.id] = 0 }
      subtotal = 0
      list_of_items = ''
      order.items.each do |item|
        next if item.count == 0
        p = item.real_price
        p = -p if item.storno_status == 2
        sum = item.count * p
        subtotal += sum
        sum_taxes[item.real_tax.id] += sum
        label = item.quantity ? "#{ item.quantity.prefix } #{ item.quantity.article.name } #{ item.quantity.postfix } #{ item.comment }" : item.article.name

        list_of_items += "%s %20.20s %7.2f %3u %7.2f\n" % [item.real_tax.letter, label, p, item.count, sum]
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
      "\n" + @current_company.invoice_slogan1 + "\n" +
      "\e!\x08" + # emphasized
      "\n" + @current_company.invoice_slogan2 + "\n" +
      @current_company.internet_address + "\n\n\n\n\n\n\n" + 
      "\x1DV\x00" # paper cut

      output = header + list_of_items + sum + tax_header + list_of_taxes + footer

      output
    end
end
