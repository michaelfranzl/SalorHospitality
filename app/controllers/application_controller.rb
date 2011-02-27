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
      redirect_to orders_path
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
      return overall_output
    end
end
