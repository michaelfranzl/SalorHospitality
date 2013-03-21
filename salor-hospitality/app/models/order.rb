# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Order < ActiveRecord::Base
  include Scope
  belongs_to :company
  belongs_to :vendor
  belongs_to :settlement
  belongs_to :table
  belongs_to :user
  belongs_to :cost_center
  belongs_to :customer
  belongs_to :tax
  belongs_to :booking
  has_many :items, :dependent => :destroy
  has_many :payment_method_items
  has_many :tax_items
  has_many :option_items
  has_many :receipts
  has_one :order

  serialize :taxes

  #validates_presence_of :user_id

  accepts_nested_attributes_for :items, :allow_destroy => true #, :reject_if => proc { |attrs| attrs['count'] == '0' || ( attrs['article_id'] == '' && attrs['quantity_id'] == '') }
  
  def customer_name
    if self.customer then
      return self.customer.full_name(true)
    end
    return ""
  end

  def customer_name=(name)
    last,first = name.split(' ')
    return if not last or not first
    c = Customer.where(:first_name => first.strip, :last_name => last.strip).first
    if not c then
      c = Customer.create(:first_name => first.strip,:last_name => last.strip, :vendor_id => self.vendor_id, :company_id => self.company_id)
      self.vendor.update_cache
    end
    self.customer = c
    self.save
  end

  def set_nr
    if self.nr.nil?
      self.update_attribute :nr, self.vendor.get_unique_model_number('order')
    end
  end

  def self.create_from_params(params, vendor, user, customer)
    order = Order.new params[:model]
    order.user = user unless order.user
    order.customer = customer if customer
    order.vendor = vendor
    order.company = vendor.company
    params[:items].to_a.each do |item_params|
      order.create_new_item(item_params)
    end
    raise "Order could not be saved." unless order.save
    #new_user = (params[:items] or self.user.nil?) ? user : nil # only change user if items were changed.
    order.update_associations(customer)
    order.regroup
    order.calculate_totals
    order.update_payment_method_items(params)
    order.hide(user.id) if order.hidden
    order.hide(user.id) unless order.items.existing.any?
    order.set_nr
    order.table.update_color
    return order
  end

  def update_from_params(params, user, customer)
    self.update_attributes params[:model]
    params[:items].to_a.each do |item_params|
      item_id = item_params[1][:id]
      if item_id
        self.update_item(item_id, item_params)
      else
        self.create_new_item(item_params)
      end
    end
    self.user = user if self.user.nil? or (params[:items] and params[:model][:user_id].nil?)
    self.save
    self.update_associations(customer)
    self.regroup
    self.calculate_totals
    self.update_payment_method_items(params)
    self.hide(user.id) if self.hidden
    self.hide(user.id) unless self.items.existing.any?
    self.table.update_color
  end
  
  def create_new_item(p)
    i = Item.new(p[1])
    i.order = self
    i.vendor = vendor
    i.company = vendor.company
    i.save
    i.create_option_items_from_ids p[1][:i]
    i.option_items.each { |oi| oi.calculate_totals }
    i.calculate_totals
    i.hide(user.id) if i.hidden
    if i.article
      i.update_attribute :statistic_category_id, i.article.statistic_category_id
    else
      message = "Could not set statistic_category_id for Item. The Item with params\n\n#{p.inspect}\n\ndid not have an Article associated with it. In rare cases, this occurs to some obscure JS issue."
      if self.vendor.enable_technician_emails == true and self.vendor.technician_email
        UserMailer.technician_message(self.vendor, "Item without Article in order.rb create_new_item", message).deliver
      else
        ActiveRecord::Base.logger.info "[TECHNICIAN] #{ message }"
      end
    end
  end
  
  def update_item(id, p)
    p[1].delete(:id)
    i = Item.find_by_id(id)
    i.update_attributes(p[1])
    i.create_option_items_from_ids p[1][:i]
    i.option_items.each { |oi| oi.calculate_totals }
    i.calculate_totals
    i.hide(user.id) if i.hidden
  end
  
  def update_payment_method_items(params)
    if params[:payment_method_items] and ( self.cost_center.nil? or (self.cost_center and self.cost_center.no_payment_methods == false))
      self.payment_method_items.clear
      params['payment_method_items'][params['id']].to_a.each do |pm|
        if pm[1]['amount'].to_f > 0 and pm[1]['_delete'].to_s == 'false'
          payment_method = self.vendor.payment_methods.existing.find_by_id(pm[1]['id'])
          PaymentMethodItem.create :payment_method_id => pm[1]['id'], :amount => pm[1]['amount'], :order_id => self.id, :vendor_id => self.vendor_id, :company_id => self.company_id, :cash => payment_method.cash
        end
      end
    end
  end

  def update_associations(customer=nil)
    self.cost_center = self.vendor.cost_centers.existing.first unless self.cost_center
    
    self.items.update_all :cost_center_id => self.cost_center
    self.tax_items.update_all :cost_center_id => self.cost_center
    self.payment_method_items.update_all :cost_center_id => self.cost_center

    self.save
    
    table = self.table
    if customer.nil?
      # when a waiter re-submits an order, @current_customer is nil. the waiter confirms all notifications by virtue of re-submitting the order.
      table.confirmations_pending = false
      table.request_finish = false
      table.request_waiter = false
    else
      table.confirmations_pending = true
    end
    table.customer = customer # is nil when waiter re-submits the order.
    table.save
    
    # Set item notifications
    remote_orders = self.vendor.remote_orders
    self.items.existing.each do |i|
      if customer.nil?
        # waiter confirms
        confirmation_count = i.count
      else
        confirmation_count = i.confirmation_count # do nothing
      end
      i.update_attributes :user_id => self.user_id, :vendor_id => self.vendor_id, :company_id => self.company_id, :preparation_user_id => i.category.preparation_user_id, :delivery_user_id => self.user_id, :confirmation_count => confirmation_count
    end
  end

  def calculate_totals
    self.sum = self.items.existing.where(:refunded => nil).sum(:sum).round(2)
    self.refund_sum = self.items.existing.where(:refunded => true).sum(:refund_sum).round(2)
    self.tax_sum = self.items.existing.where(:refunded => nil).sum(:tax_sum).round(2)
    self.calculate_taxes
    self.save
  end
  
  def calculate_taxes
    self.taxes = {}
    self.items.existing.where(:refunded => nil).each do |item|
      item.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:t] += v[:t]
          self.taxes[k][:g] += v[:g]
          self.taxes[k][:n] += v[:n]
          self.taxes[k][:t] =  self.taxes[k][:t].round(2)
          self.taxes[k][:g] =  self.taxes[k][:g].round(2)
          self.taxes[k][:n] =  self.taxes[k][:n].round(2)
        else
          self.taxes[k] = v
        end
      end
    end
    self.save
  end

  def hide(by_user_id)
    self.vendor.unused_order_numbers << self.nr
    self.vendor.save
    self.nr = nil
    self.hidden = true
    self.hidden_by = by_user_id
    self.save
    self.unlink
    self.option_items.update_all :hidden => true, :hidden_by => by_user_id
    self.tax_items.update_all :hidden => true, :hidden_by => by_user_id
    self.items.update_all :hidden => true, :hidden_by => by_user_id
    self.payment_method_items.update_all :hidden => true, :hidden_by => by_user_id
  end

  def unlink
    split_order = self.order
    if split_order
      split_order.items.update_all :item_id => nil
      split_order.order = nil
      split_order.save
    end
    self.order = nil
    self.save
    self.items.update_all :item_id => nil
  end

  def move(target_table_id)
    return if self.table_id == target_table_id.to_i
    target_order = Order.existing.where(:table_id => target_table_id, :finished => false).first
    self.unlink
    self.reload
    origin_table = self.table
    target_table = Table.find_by_id target_table_id

    if target_order
      self.items.update_all :order_id => target_order.id
      self.option_items.update_all :order_id => target_order.id
      self.tax_items.update_all :order_id => target_order.id
      self.reload
      self.calculate_totals
      self.hide(-1)
      target_order.regroup
      #target_order.items.existing.each { |i| i.calculate_totals } # this is already called in .regroup
      target_order.calculate_totals
    else
      self.table_id = target_table_id
      self.save
    end
    origin_table.update_color
    target_table.update_color
  end

  def regroup
    items = self.items.existing
    n = items.size - 1
    0.upto(n-1) do |i|
      (i+1).upto(n) do |j|
        if (items[i].article_id  == items[j].article_id    and
            items[i].quantity_id == items[j].quantity_id   and
            items[i].option_items.existing.collect{|oi| oi.option.id}.uniq.sort == items[j].option_items.existing.collect{|oi| oi.option.id}.uniq  and
            items[i].price       == items[j].price         and
            items[i].comment     == items[j].comment       and
            items[i].scribe      == items[j].scribe        and
            items[i].refunded    == nil                    and
            items[j].refunded    == nil                    and
            not items[i].destroyed?
            )
          items[i].count += items[j].count
          items[i].printed_count += items[j].printed_count
          items[i].save # this is needed for the next step
          items[i].option_items.each{|oi| oi.calculate_totals }
          items[i].calculate_totals
          items[j].hide(-2)
        end
      end
    end
  end

  def finish(user=nil)
    self.finished_at = Time.now
    self.user = user if user
    self.finished = true
    Item.connection.execute("UPDATE items SET confirmation_count = count, preparation_count = count, delivery_count = count WHERE vendor_id=#{self.vendor_id} AND  company_id=#{self.company_id} AND order_id=#{self.id};")
    self.save
    self.unlink
    self.set_nr
    self.table.update_color
    self.items.existing.each do |i|
      i.option_items.existing.each do |oi|
        oi.hide(-10) if oi.price == 0.0
      end
    end
    self.regroup
  end

  def pay(user=nil)
    return if self.hidden # this happens when called from application_controller, 'pay_and_no_print' when splitting an item and order is deleted.
    self.finish(user)
    # create a default cash payment method item if none was set in the UI
    unless self.payment_method_items.existing.any? or (self.cost_center and self.cost_center.no_payment_methods == true)
      cash_payment_methods = self.vendor.payment_methods.existing.where(:cash => true)
      cash_payment_method = cash_payment_methods.first
      if cash_payment_method
        PaymentMethodItem.create :company_id => self.company_id, :vendor_id => self.vendor_id, :order_id => self.id, :payment_method_id => cash_payment_method.id , :cash => true, :amount => self.sum
      end
    end
    
    payment_method_sum = self.payment_method_items.existing.sum(:amount) # refunded is never true at this point
    
    # create a change payment method item
    unless self.payment_method_items.existing.where(:change => true).any? or (self.cost_center and self.cost_center.no_payment_methods == true)
      change_payment_methods = self.vendor.payment_methods.where(:change => true)
      if change_payment_methods.any?
        PaymentMethodItem.create :company_id => self.company_id, :vendor_id => self.vendor_id, :order_id => self.id, :change => true, :amount => (payment_method_sum - self.sum).round(2), :payment_method_id => change_payment_methods.first.id
      end
    end
    
    self.payment_method_items.update_all :cost_center_id => self.cost_center_id
    
    self.change_given = (payment_method_sum - self.sum).round(2)
    self.paid = true
    self.paid_at = Time.now
    self.save
    self.table.update_color
  end
  
  def reactivate(user)
    # try to restore the original table
    used_table = self.vendor.tables.existing.where(:id => self.table_id, :active_user_id => nil).first
    if used_table.nil?
      # if original table is occupied, use the first empty table
      used_table = self.vendor.tables.existing.where(:active_user_id => nil).first
    end
    return nil unless used_table
    self.table_id = used_table.id
    self.finished = false
    self.finished_at = nil
    self.reactivated  = true
    self.reactivated_by = user.id
    self.reactivated_at = Time.now
    self.user_id = user.id
    self.paid = false
    self.change_given = nil
    self.taxes = {}
    self.paid_at = nil
    self.save
    self.payment_method_items.update_all :hidden => true, :hidden_by => user.id
    used_table.update_color
    return used_table
  end

  def print(what, vendor_printer=nil, options={})
    # The print location of a receipt is always chosen from the UI and controlled here by the parameter vendor_printer. The print location of tickets are only determined by the Category.vendor_printer_id setting.
    if what.include? 'tickets'
      vendor_printers = self.vendor.vendor_printers.existing
      print_engine = Escper::Printer.new(self.company.mode, vendor_printers, self.company.identifier)
    else
      print_engine = Escper::Printer.new(self.company.mode, vendor_printer, self.company.identifier)
    end

    print_engine.open

    # print
    if what.include? 'tickets'
      unless self.vendor.categories.existing.all? {|c| c.vendor_printer_id == nil}
        vendor_printers.each do |p|
          contents = self.escpos_tickets(p.id)
          unless contents[:text].empty?
            bytes_written, content_sent = print_engine.print(p.id, contents[:text], contents[:raw_insertations])
            bytes_sent = content_sent.length
            Receipt.create(:vendor_id => self.vendor_id, :company_id => self.company_id, :user_id => self.user_id, :vendor_printer_id => p.id, :order_id => self.id, :order_nr => self.nr, :content => contents[:text], :bytes_sent => bytes_sent, :bytes_written => bytes_written)
          end
        end
      end
    end
    
    if what.include? 'receipt'
      if vendor_printer
        contents = self.escpos_receipt(options)
        bytes_written, content_sent = print_engine.print(vendor_printer.id, contents[:text], contents[:raw_insertations])
        bytes_sent = content_sent.length
        Receipt.create(:vendor_id => self.vendor_id, :company_id => self.company_id, :user_id => self.user_id, :vendor_printer_id => vendor_printer.id, :order_id => self.id, :order_nr => self.nr, :content => contents[:text], :bytes_sent => bytes_sent, :bytes_written => bytes_written)
        self.update_attribute :printed, true
      end
    end
    
    if what.include? 'interim_receipt'
      # this is currently not implemented and never called.
      if vendor_printer
        print_engine.print(vendor_printer.id, self.escpos_interim_receipt)
      end
    end
    print_engine.close
  end

  def escpos_tickets(printer_id)
    vendor = self.vendor
    if vendor.ticket_wide_font
      header_format_time_order = "%-14.14s #%5i\n"
      header_format_user_table = "%-12.12s %8s\n"
      header_note_format = "%20.20s\n"
      article_format = "%i %-18.18s\n"
      quantity_format  = " > %-18.18s\n"
      comment_format   = " ! %-18.18s\n"
      option_format    = " * %-18.18s\n"
      width = 21
      item_separator_format = "\xC4" * (width - 7) + " %6.2f\n"
    else
      header_format_time_order = "%-35.35s #%5i\n"
      header_format_user_table = "%-33.33s %8s\n"
      header_note_format = "%42.42s\n"
      article_format     = "%2i %-39.39s\n"
      quantity_format    = "   > %-37.37s\n"
      comment_format     = "   ! %-37.37s\n"
      option_format      = "   * %-37.37s\n"
      width = 42
      item_separator_format = "\xC4" * (width - 7) + " %6.2f\n"
    end

    if vendor.ticket_wide_font and not vendor.ticket_tall_font
      fontsize = 0x20
    elsif not vendor.ticket_wide_font and vendor.ticket_tall_font
      fontsize = 0x10
    elsif vendor.ticket_wide_font and vendor.ticket_tall_font
      fontsize = 0x30
    else
      fontsize = 0x00
    end
    fontstyle = fontsize | 0x08

    init =
    "\e@" +  # Initialize Printer
    "\e!" +
    fontstyle.chr +
    "\n\n\n\n\n"

    cut =
    "\n\n\n\n\n\n" +
    "\x1D\x56\x00" +        # paper cut
    "\x1B\x70\x00\x99\x99\x0C"  # beep

    header = ''
    
    nr = self.nr ? self.nr : 0 # failsafe for the sprintf command below
    if vendor.ticket_display_time_order
      header += header_format_time_order % [I18n.l(Time.now + vendor.time_offset.hours, :format => :time_short), (vendor.use_order_numbers ? nr : 0)]
    end

    header += header_format_user_table % [self.user.login, self.table.name]

    header += header_note_format % [self.note] if self.note and not self.note.empty?
    header += "\xDF" * width + "\n"

    separate_receipt_contents = []
    normal_receipt_content = ''
      
    selected_categories = printer_id.nil? ? self.vendor.categories.existing.active : self.vendor.categories.existing.active.where(:vendor_printer_id => printer_id)
    
    raw_insertations = {}
    selected_categories.each do |c|
      items = self.items.existing.where("count > printed_count AND category_id = #{ c.id }")
      catstring = ''
      items.each do |i|
        next if i.option_items.find_all_by_no_ticket(true).any?
        itemstring = ''
        itemstring += article_format % [ i.count - i.printed_count, i.article.name]
        itemstring += quantity_format % ["#{i.quantity.prefix} #{i.quantity.postfix}"] if i.quantity
        itemstring += comment_format % [i.comment] unless i.comment.empty?
        i.option_items.each do |oi|
          itemstring += option_format % [oi.name]
        end
        
        if i.scribe_escpos
          raw_insertations.merge! :"scribe#{i.id}" => i.scribe_escpos.force_encoding('ASCII-8BIT')
          markup = "{::escper}scribe#{i.id}{:/}"
          itemstring += markup
        end

        if vendor.ticket_item_separator
          itemstring += item_separator_format % [(i.price + i.options_price) * (i.count - i.printed_count)]
        end
        
        if i.option_items.find_all_by_separate_ticket(true).any?
          separate_receipt_contents << itemstring
        else
          catstring += itemstring
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
      unless content.empty?
        output +=
            header +
            content +
            cut
      end
    end
    
    unless normal_receipt_content.empty?
      output +=
          header +
          normal_receipt_content +
          cut
    end
    
    if output == init
      return {:text => '', :raw_insertations => {}}
    else
      return {:text => output, :raw_insertations => raw_insertations }
    end
  end


  def escpos_receipt(options={})
    vendor = self.vendor
    
    friendly_unit = I18n.t('number.currency.format.friendly_unit', :locale => SalorHospitality::Application::COUNTRIES_REGIONS[vendor.country])

    vendorname =
    "\e@"     +  # Initialize Printer
    "\e!\x38" +  # doube tall, double wide, bold
    vendor.name + "\n"

    header1 = ''
    header1 +=
    "\e!\x01" +  # Font B
    "\ea\x01" +  # center
    "\n" + vendor.receipt_header_blurb + "\n" if vendor.receipt_header_blurb
    
    lines = ''
    if options[:with_customer_lines] == true
      lines += "\e!\x00"  # Font A
      4.times do |i|
        lines += "\xc4" * 42 + "\n\n"
      end
    end
    
    header2 = ''
    header2 +=
    "\ea\x00" +  # align left
    "\e!\x01" +  # Font B
    I18n.t('served_by_X_on_table_Y', :waiter => self.user.title, :table => self.table.name) + "\n"

    header2 += I18n.t('invoice_numer_X_at_time', :number => self.nr, :datetime => I18n.l(self.created_at + vendor.time_offset.hours, :format => :long)) if vendor.use_order_numbers

    header2 += "\n\n" +
    "\e!\x00" +  # Font A
    "                 #{I18n.t('activerecord.models.article.one')}   #{I18n.t('various.unit_price_abbreviation')}   #{I18n.t('various.quantity_abbreviation')}    #{I18n.t('various.total_price_abbreviation')}\n" +
    "\xc4" * 42 + "\n"

    list_of_items = ''
    self.items.existing.positioned.each do |item|
      next if item.count == 0
      list_of_options = ''
      item.option_items.each do |oi|
        next if oi.price == 0
        list_of_options += "%2s %21.21s %6.2f %3u %6.2f\n" % [item.taxes.collect{|k,v| v[:l]}[0..1].join(''), "#{ I18n.t(:refund) + ' ' if item.refunded}#{ oi.name }", oi.price, item.count, item.refunded ? 0 : (oi.price * item.count)]
      end

      label = item.quantity ? "#{ I18n.t(:refund) + ' ' if item.refunded }#{ item.quantity.prefix } #{ item.quantity.article.name }#{ ' ' unless item.quantity.postfix.empty? }#{ item.quantity.postfix }" : "#{ I18n.t(:refund) + ' ' if item.refunded }#{ item.article.name }"

      item_sum = item.refunded ? 0 : item.price * item.count
      list_of_items += "%2s %21.21s %6.2f %3u %6.2f\n" % [item.taxes.collect{|k,v| v[:l]}[0..1].join(''), label, item.price, item.count, item_sum]
      list_of_items += list_of_options
    end

    sum_format =
    "                              " + "\xcd" * 12 + "\r\n" +
    "\e!\x18" + # double tall, bold
    "\ea\x02"   # align right

    sum = "#{I18n.t(:sum).upcase}:   #{friendly_unit} %.2f" % self.sum

    refund = self.refund_sum.zero? ? '' : ("\n#{I18n.t(:refund)}:  #{friendly_unit} %.2f" % self.refund_sum)

    tax_format =
        "\n\n" +
        "\ea\x01" +  # align center
        "\e!\x01" # Font A

    tax_header = "         #{I18n.t(:net)}  #{I18n.t('various.tax')}   #{I18n.t(:gross)}\n"

    list_of_taxes = ''
    self.taxes.each do |k,v|
      list_of_taxes += "%s: %2i%% %7.2f %7.2f %8.2f\n" % [v[:l],v[:p],v[:n], v[:t], v[:g]]
    end
    
    list_of_payment_methods = "\n"
    if self.user.role.permissions.include? 'manage_payment_methods'
      self.payment_method_items.each do |pm|
        name = pm.refunded ? "#{ I18n.t(:refund) } #{ pm.refund_item.article.name } #{pm.payment_method.name}" : pm.payment_method.name
        list_of_payment_methods += "%22.22s: %7.2f\n" % [name, pm.amount] unless pm.amount.zero?
      end
    end

    footer = ''
    if vendor.receipt_footer_blurb
      footer = 
      "\ea\x01" +  # align center
      "\e!\x00" + # font A
      "\n" +
      vendor.receipt_footer_blurb +
      "\n"
    end

    duplicate = self.printed ? " *** DUPLICATE/COPY/REPRINT *** " : ''
    
    raw_insertations = {}
    if vendor.rlogo_header
      headerlogo = "{::escper}headerlogo{:/}"
      raw_insertations.merge! :headerlogo => vendor.rlogo_header
    else
      headerlogo = vendorname
    end
    
    if vendor.rlogo_footer
      footerlogo = "{::escper}footerlogo{:/}"
      raw_insertations.merge! :footerlogo => vendor.rlogo_footer
    else
      footerlogo = ''
    end

    output_text =
        "\e@" +     # initialize
        "\ea\x01" + # align center
        headerlogo +
        header1 +
        lines +
        header2 +
        list_of_items +
        sum_format +
        sum +
        refund +
        tax_format +
        tax_header +
        list_of_taxes +
        list_of_payment_methods +
        footer +
        duplicate +
        "\n" +
        footerlogo +
        "\n\n\n\n\n\n" +
        "\x1DV\x00\x0C" # paper cut
    return { :text => output_text, :raw_insertations => raw_insertations }
  end
  
  def escpos_interim_receipt
    return "To be implemented in the future."
  end

  def items_to_json
    a = {}
    self.items.existing.positioned.reverse.each do |i|
      if i.quantity_id
        d = "q#{i.quantity_id}"
      else
        d = "a#{i.article_id}"
      end
      parent_price = i.quantity ? i.quantity.price : i.article.price
      if i.option_items.any? or not i.comment.empty? or i.scribe or i.price != parent_price
        d = "i#{i.id}"
      end
      options = {}
      optioncount = 0
      i.option_items.existing.each do |oi|
        optioncount += 1
        options.merge! optioncount => { :id => oi.option_id, :n => oi.name, :p => oi.price }
      end
      if i.quantity_id
        a.merge! d => { :id => i.id, :ci => i.category_id, :ai => i.article_id, :qi => i.quantity_id, :d => d, :c => i.count, :sc => i.count, :p => i.price, :o => i.comment, :t => options, :i => [], :pre => i.quantity.prefix, :post => i.quantity.postfix, :n => i.article.name, :s => i.position, :h => !i.scribe.nil? }
      else
        a.merge! d => { :id => i.id, :ci => i.category_id, :ai => i.article_id, :d => d, :c => i.count, :sc => i.count, :p => i.price, :o => i.comment, :t => options, :i => [], :pre => '', :post => '', :n => i.article.name, :s => i.position, :h => !i.scribe.nil? }
      end
    end
    return a.to_json
  end
  
  def invoice_items_to_json
    # to be implemented
  end
  
  def check
    messages = []
    tests = []
    self.items.each do |i|
      messages << i.check
    end
    
    order_hash_tax_sum = 0
    self.taxes.each do |k,v|
      order_hash_tax_sum += v[:t]
    end
    tests[1] = order_hash_tax_sum.round(2) == self.tax_sum.round(2)

    unless self.hidden
      tests[2] = self.tax_sum.round(2) == self.tax_items.where(:refunded => nil).existing.sum(:tax).round(2)
      tests[3] = self.items.where(:refunded => nil).existing.sum(:sum).round(2) == self.sum.round(2)
      tests[4] = self.items.where(:refunded => nil).existing.sum(:tax_sum).round(2) == self.tax_sum.round(2)
      
      # order sum must match the PAYMENT METHOD ITEM sum
      if self.paid and (self.cost_center.nil? or self.cost_center.no_payment_methods != true)
        tests[5] = self.sum.round(2) == (self.payment_method_items.existing.where(:refunded => nil, :change => false).sum(:amount) - self.payment_method_items.existing.where(:refunded => nil, :change => true).sum(:amount) - self.payment_method_items.existing.where(:refunded => true).sum(:amount)).round(2)
      end
      
      if self.paid and self.cost_center and self.cost_center.no_payment_methods == true
        tests[6] = self.payment_method_items.any? == false
      end
    end

    # cost_center_id may only be nil if there are no CostCenters defined
    tests[8] = self.cost_center_id or (self.cost_center_id.nil? and not self.vendor.cost_centers.existing.any?)
    
    # all associations must have the same COST CENTER
    tests[12] = self.items.collect{ |i| i.cost_center_id == self.cost_center_id }.all?
    tests[13] = self.tax_items.collect{ |i| i.cost_center_id == self.cost_center_id }.all?
    tests[14] = self.payment_method_items.collect{ |i| i.cost_center_id == self.cost_center_id }.all?
    
    # all associations must have the same SETTLEMENT
    tests[15] = self.items.collect{ |i| i.settlement_id == self.settlement_id }.all?
    tests[16] = self.tax_items.collect{ |i| i.settlement_id == self.settlement_id }.all?
    tests[17] = self.payment_method_items.collect{ |i| i.settlement_id == self.settlement_id }.all?
    
    # all associations must be HIDDEN
    if self.hidden
      tests[18] = self.items.collect{ |i| i.hidden == self.hidden }.all?
      tests[19] = self.tax_items.collect{ |i| i.hidden == self.hidden }.all?
    end
    tests[20] = self.payment_method_items.collect{ |i| i.hidden == self.hidden }.all?
    
    # finished orders have to have nr set
    if self.finished
      tests[21] = self.nr.nil? == false
    end

    0.upto(tests.size-1).each do |i|
      messages << "Order #{ self.id }: test#{i} failed." if tests[i] == false
    end
    return messages
  end
  
  def user_login
    if self.user
      return self.user.login if self.user
    else
      return self.customer.login if self.customer
    end
  end
end
