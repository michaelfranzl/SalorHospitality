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
    
    return unless $Vendor.history_print == true
    # Printing changes, in accordance to fiscal regulations
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
    if vendor_printers.any? and keys.any? and [User, Vendor, Tax, CostCenter, PaymentMethod, Table].include?(object.class)
      output = "\e@" +
          "\e!\x38" +       # big font
          "UPDATE #{ object.class.to_s } ID #{ object.id }\n" +
          I18n.l(Time.now, :format => :datetime_iso2) +
          "\e!\x00" +        # normal font
          "\n\n"
      keys.each do |k|
        output += "#{ k }: #{ changes[k] }\n"
      end
      output += "\n\n\n\n\n\n\n" +         # space
            "\x1DV\x00\x0C"            # paper cut
      print_engine = Escper::Printer.new($Vendor.company.mode, vendor_printers, $Vendor.company.identifier)
      print_engine.open
      print_engine.print(vendor_printers.first.id, output)
      print_engine.close
    end
  end
  
  def after_create(object)
    History.record("#{object.class.to_s}_created", object)
  end
  
  def before_destroy(object)
    History.record("#{object.class.to_s}_destroyed", object)
  end
end
