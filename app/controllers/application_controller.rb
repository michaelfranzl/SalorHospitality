# coding: utf-8

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

  helper :all # include all helpers, all the time
  before_filter :fetch_logged_in_user, :set_locale, :set_automatic_printing, :initialize_printers
  helper_method :logged_in?, :mobile?, :workstation?, :saas_variant?, :local_variant?, :test_printers

  private

    def local_request?
      false
    end

    def rescue_action_in_public(exception)
      if request.xhr?
        render 'sessions/error', :locals => { :exception => exception }
      else
        redirect_to orders_path
      end
    end

    def fetch_logged_in_user
      @current_user = User.find session[:user_id] if session[:user_id]
      @current_company = @current_user.company if @current_user
      if not @current_company
        @current_company = Company.create
        @current_user.company = @current_company
        @current_user.save
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

    def set_automatic_printing
      session[:automatic_printing] = @current_company.automatic_printing if session[:automatic_printing].nil? and @current_company
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
      else
        # find Order with largest nr attribute from database. this should happen only once per application instance.
        last_order = Order.first(:order => 'nr DESC')
        nr = last_order ? last_order.nr + 1 : 1
      end
      return nr
    end

    def initialize_printers
      return if saas_variant? or not @current_company or not BillGastro::Application::printers.empty?

      printer_paths = [@current_company.printer_kitchen, @current_company.printer_bar, @current_company.printer_guestroom]
      (0..2).each { |i|
        # try to open serial port
        begin
          BillGastro::Application::printers[i] = SerialPort.new printer_paths[i], 9600
        rescue
          BillGastro::Application::printers[i] = nil
        end

        next if BillGastro::Application::printers[i]

        # try to open USB port
        begin
          BillGastro::Application::printers[i] = File.open printer_paths[i], 'w:ISO8859-15'
        rescue
          BillGastro::Application::printers[i] = BillGastro::DummyPrinter.new i
        end
      }
    end

    def test_printers
      file = File.open('public/test.bill', 'rb')
      test_invoice = file.read
      BillGastro::Application::printers = []
      initialize_printers
      (0..2).each { |i| BillGastro::Application::printers[i].write test_invoice }
    end

    def generate_escpos_items(order = nil, category_usage = nil, article_usage = nil)
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
          next if i.count == i.printed_count

          article_quantity_usage = i.quantity ? i.quantity.usage : i.article.usage

          next if category_usage and
                  article_usage and
                  ((i.count <= i.printed_count)         or
                  (category_usage != i.category.usage) or
                  (article_usage  != article_quantity_usage))

          printed_items_in_this_order =+ 1

          per_order_output += "%i %-18.18s\n" % [ i.count - i.printed_count, i.article.name]
          per_order_output += "  %-18.18s\n" % ["#{i.quantity.prefix} #{ i.quantity.postfix}"] if i.quantity
          per_order_output += "! %-18.18s\n" % [i.comment] if i.comment and not i.comment.empty?

          i.printoptions.each do |po|
            per_order_output += "* %-18.18s\n" % [po.name]
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
        logger.info per_order_output + "\n\n"
      end

      overall_output.gsub!(/ä/,"ae")
      overall_output.gsub!(/ü/,"ue")
      overall_output.gsub!(/ö/,"oe")
      overall_output.gsub!(/Ä/,"Ae")
      overall_output.gsub!(/Ü/,"Ue")
      overall_output.gsub!(/Ö/,"Oe")
      overall_output.gsub!(/ß/,"sz")
      overall_output.gsub!(/é/,"e")
      overall_output.gsub!(/è/,"e")
      overall_output.gsub!(/ú/,"u")
      overall_output.gsub!(/ù/,"u")
      overall_output.gsub!(/É/,"E")

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
        p = item.real_price
        p = -p if item.storno_status == 2
        sum = item.count * p
        subtotal += sum
        sum_taxes[item.real_tax.id] += sum
        label = item.quantity ? "#{ item.quantity.prefix } #{ item.quantity.article.name } #{ item.quantity.postfix } #{ item.comment }" : item.article.name

        label.gsub!(/ä/,"ae")
        label.gsub!(/ü/,"ue")
        label.gsub!(/ö/,"oe")
        label.gsub!(/Ä/,"Ae")
        label.gsub!(/Ü/,"Ue")
        label.gsub!(/Ö/,"Oe")
        label.gsub!(/ß/,"sz")
        label.gsub!(/é/,"e")
        label.gsub!(/è/,"e")
        label.gsub!(/ú/,"u")
        label.gsub!(/ù/,"u")
        label.gsub!(/É/,"E")

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
        net = sum_taxes[tax.id]/(1.00+fact)
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
      logger.info output

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
      output
    end
end
