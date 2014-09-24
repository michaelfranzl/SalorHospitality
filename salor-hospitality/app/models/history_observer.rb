# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class HistoryObserver < ActiveRecord::Observer
  observe :article, :quantity, :category, :tax, :table, :company, :cost_center, :customer, :guest_type, :option, :page, :payment_method, :presentation, :role, :room, :room_price, :room_type, :season, :settlement, :statistic_category, :surcharge, :tax_amount, :vendor_printer, :user, :vendor
  
  def after_update(object)
    History.record("#{object.class.to_s}_updated", object)
    
    # Printing changes, in accordance to fiscal regulations
    return unless $Vendor and $Vendor.respond_to?(:history_print) and  $Vendor.history_print == true
    
    vendor_printers = $Vendor.vendor_printers.existing
    changes = object.changes
    keys = changes.keys
    keys.delete('updated_at')
    keys.delete('resources_cache')
    keys.delete('left')
    keys.delete('top')
    keys.delete('left_mobile')
    keys.delete('top_mobile')
    keys.delete('largest_order_number')
    keys.delete('active_user_id')
    keys.delete('request_finish')
    keys.delete('request_waiter')
    keys.delete('confirmations_pending')
    keys.delete('current_ip')
    keys.delete('last_active_at')
    keys.delete('last_login_at')
    keys.delete('last_logout_at')
    keys.delete('last_active_at')
    keys.delete('largest_settlement_number')
    keys.delete('current_settlement_id')
    if vendor_printers.any? and keys.any? and [User, Vendor, Tax, CostCenter, PaymentMethod, Table, Article, Quantity].include?(object.class)
      output = "\e@" +
          "\e!\x38" +       # big font
          "UPDATE\n#{ object.class.to_s } ID #{ object.id }\n" +
          I18n.l(Time.now, :format => :datetime_iso2) +
          "\e!\x00" +        # normal font
          "\n\n" +
          "#{ $User.login }@#{ $Request.remote_ip }" +
          "\n\n"
      keys.each do |k|
        output += "#{ k }: #{ changes[k] }\n"
      end
      output += "\n\n\n\n\n\n\n" +         # space
            "\x1DV\x00\x0C"            # paper cut
      print_engine = Escper::Printer.new($Vendor.company.mode, vendor_printers, File.join(SalorHospitality::Application::SH_DEBIAN_SITEID, $Vendor.hash_id))
      print_engine.open
      bytes_written, content_sent = print_engine.print(vendor_printers.first.id, output)
      print_engine.close
      r = Receipt.new
      r.user_id = $User.id
      r.content = output
      r.vendor_id = $Vendor.id
      r.company_id = $Company.id
      r.vendor_printer_id = vendor_printers.first.id
      r.bytes_sent = content_sent.length
      r.bytes_written = bytes_written
      r.save
    end
  end
  
  def after_create(object)
    History.record("#{object.class.to_s}_created", object)
  end
  
  def before_destroy(object)
    History.record("#{object.class.to_s}_destroyed", object)
  end
end
