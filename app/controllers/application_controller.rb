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
  # protect_from_forgery

  helper :all # include all helpers, all the time
  before_filter :fetch_logged_in_user, :set_locale
  helper_method :logged_in?, :ipod?, :workstation?

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
      render 'go_to_login' if (request.xhr? and !@current_user) #only when user is logging out on ipod, for normal request let the views handle the login form diplay
    end

    def logged_in?
      ! @current_user.nil?
    end

    def workstation?
       request.user_agent.include?('Firefox') or request.user_agent.include?('MSIE') or request.user_agent.include?('Macintosh')
      #not ipod?
    end

    def ipod?
      not workstation?
    end

    def set_locale
      I18n.locale = @current_user.language if @current_user
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
      if MyGlobals::unused_order_numbers.empty?
        nr = MyGlobals::last_order_number += 1
      else
        nr = MyGlobals::unused_order_numbers.first
        MyGlobals::unused_order_numbers.delete(nr)
      end
      return nr
    end

    def generate_escpos_items(order, type)
      overall_output = ''
      #Order.find_all_by_finished(false).each do |order|
        per_order_output = ''
        per_order_output +=
        "\e@"     +  # Initialize Printer
        "\e!\x38" +  # doube tall, double wide, bold

        "%-14.14s #%5i\n%-12.12s %8s\n" % [l(Time.now, :format => :time_short), order.nr, @current_user.login, order.table.abbreviation] +

        per_order_output += "=====================\n"

        printed_items_in_this_order = 0
        order.items.each do |i|

          next if (i.count <= i.printed_count)
          next if (type == :drink and i.category.food) or (type == :food and !i.category.food)

          usage = i.quantity ? i.quantity.usage : i.article.usage
          next if (type == :takeaway and usage != 'b') or (type != :takeaway and usage == 'b')

          printed_items_in_this_order =+ 1

          per_order_output += "%i %-18.18s\n" % [ i.count - i.printed_count, i.article.name]
          per_order_output += "  %-18.18s\n" % ["#{i.quantity.prefix} #{ i.quantity.postfix}"] if i.quantity
          per_order_output += "! %-18.18s\n" % [i.comment] if i.comment and not i.comment.empty?

          i.options.each { |o| per_order_output += "* %-18.18s\n" % [o.name] }

          #per_order_output += "---------------------\n"

          i.update_attribute :printed_count, i.count
        end

        per_order_output +=
        "\n\n\n\n" +
        "\x1DV\x00" # paper cut at the end of each order/table
        overall_output += per_order_output if printed_items_in_this_order != 0
      #end

      overall_output = Iconv.conv('ISO-8859-15','UTF-8',overall_output)
      overall_output.gsub!(/\x00E4/,"\x84") #ä
      overall_output.gsub!(/\x00FC/,"\x81") #ü
      overall_output.gsub!(/\x00F6/,"\x94") #ö
      overall_output.gsub!(/\x00C4/,"\x8E") #Ä
      overall_output.gsub!(/\x00DC/,"\x9A") #Ü
      overall_output.gsub!(/\x00D6/,"\x99") #Ö
      overall_output.gsub!(/\x00DF/,"\xE1") #ß
      overall_output.gsub!(/\x00E9/,"\x82") #é
      overall_output.gsub!(/\x00E8/,"\x7A") #è
      overall_output.gsub!(/\x00FA/,"\xA3") #ú
      overall_output.gsub!(/\x00F9/,"\x97") #ù
      overall_output.gsub!(/\x00C9/,"\x90") #É
      puts overall_output
      return overall_output
    end

    def generate_escpos_test
      out = "\e@" # Initialize Printer
      0.upto(255) { |i|
        out += i.to_s + i.chr
      }
      return out
    end

    def generate_escpos_invoice(order)
      client_data = File.exist?('config/client_data.yml') ? YAML.load_file( 'config/client_data.yml' ) : { :name => '', :subtitle => '', :address => '', :taxnumber => '', :slogan1 => '', :slogan2 => '', :internet => '' }

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
      puts output
      return output
    end
end
