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
  has_one :order

  serialize :taxes

  validates_presence_of :user_id

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

  def self.create_from_params(params, vendor, user)
    order = Order.new
    order.user = user
    order.vendor = vendor
    order.company = vendor.company
    order.update_attributes params[:model]
    params[:items].to_a.each do |item_params|
      new_item = Item.new(item_params[1])
      new_item.hidden_by = user.id if new_item.hidden
      #new_item.hide(user) if new_item.count.zero? # 0 cout items are allowed, unlike OrderItems
      new_item.order = order
      #new_item.cost_center = order.cost_center
      new_item.save
      new_item.update_option_items_from_ids(item_params[1][:i]) if item_params[1][:i]
      new_item.option_items.each do |oi|
        oi.hidden = new_item.hidden
        oi.hidden_by = new_item.hidden_by
        oi.calculate_totals
      end
      new_item.calculate_totals
    end
    order.save
    #debugger
    order.update_associations(user)
    order.calculate_totals
    order.update_payment_method_items(params)
    return order
  end

  def update_from_params(params, user)
    self.update_attributes params[:model]
    params[:items].to_a.each do |item_params|
      item_id = item_params[1][:id]
      if item_id
        item_params[1].delete(:id)
        item = Item.find_by_id(item_id)
        item.update_attributes(item_params[1])
        item.hidden_by = user.id if item.hidden
        item.hide(user) if item.count.zero?
        item.update_option_items_from_ids(item_params[1][:i]) if item_params[1][:i]
        item.option_items.each do |oi|
          oi.hidden = item.hidden
          oi.hidden_by = item.hidden_by
          oi.calculate_totals
        end
        item.calculate_totals
      else
        new_item = Item.new(item_params[1])
        new_item.hidden_by = user.id if new_item.hidden
        new_item.order = self
        #new_item.cost_center = self.cost_center
        new_item.save
        new_item.update_option_items_from_ids(item_params[1][:i]) if item_params[1][:i]
        new_item.option_items.each do |oi|
          oi.hidden = new_item.hidden
          oi.hidden_by = new_item.hidden_by
          oi.calculate_totals
        end
        new_item.calculate_totals
      end
    end
    self.save
    self.update_associations(user)
    self.update_payment_method_items(params)
  end
  
  def update_payment_method_items(params)
    if params[:payment_method_items] then
      self.payment_method_items.clear
      params['payment_method_items'][params['id']].to_a.each do |pm|
        if pm[1]['amount'].to_f > 0 and pm[1]['_delete'].to_s == 'false'
          PaymentMethodItem.create :payment_method_id => pm[1]['id'], :amount => pm[1]['amount'], :order_id => self.id, :vendor_id => self.vendor_id, :company_id => self.company_id
        end
      end
    end
  end

  def update_associations(user)
    if self.table
      self.table.user = user
      self.table.save
    else
      raise "Oops. Order didn't have a table associated to it. This shouldn't have happened."
    end
    self.user = user
    save
    
    Item.where(:order_id => self.id).update_all :vendor_id => self.vendor.id, :company_id => self.company.id
    TaxItem.where(:order_id => self.id).update_all :vendor_id => self.vendor.id, :company_id => self.company.id
    OptionItem.where(:order_id => self.id).update_all :vendor_id => self.vendor.id, :company_id => self.company.id
    # Clear item notifications
    self.items.where( :user_id => nil, :preparation_user_id => nil, :delivery_user_id => nil ).each do |i|
      i.update_attributes :user_id => user.id, :vendor_id => self.vendor.id, :company_id => self.company.id, :preparation_user_id => i.category.preparation_user_id, :delivery_user_id => user.id
    end 
  end

  def calculate_totals
    self.sum = items.existing.sum(:sum).round(2)
    self.refund_sum = items.existing.sum(:refund_sum).round(2) #frozen hash
    #self.tax_sum = items.existing.sum(:tax_sum)
    self.taxes = {}
    self.items.each do |item|
      item.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:t] += v[:t].round(2)
          self.taxes[k][:g] += v[:g].round(2)
          self.taxes[k][:n] += v[:n].round(2)
          self.taxes[k][:t] =  self.taxes[k][:t].round(2)
          self.taxes[k][:g] =  self.taxes[k][:g].round(2)
          self.taxes[k][:n] =  self.taxes[k][:n].round(2)
        else
          self.taxes[k] = v
        end
      end
    end
    save
  end

  def hide(by_user_id)
    self.vendor.unused_order_numbers << self.nr
    self.vendor.save
    self.table.user = nil
    self.table.save
    self.hidden = true
    self.hidden_by = by_user_id
    self.nr = nil
    save
    self.option_items.update_all :hidden => true, :hidden_by => by_user_id if self.option_items.any?
    self.tax_items.update_all :hidden => true, :hidden_by => by_user_id if self.tax_items.any?
  end

  def unlink
    self.items.update_all :item_id => nil
    self.update_attribute :order_id, nil
    parent_order = self.order
    if parent_order
      parent_order.items.update_all :item_id => nil
      parent_order.update_attribute :order_id, nil
    end
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
      self.reload
      self.destroy
      target_order.calculate_totals
      target_order.regroup
    else
      self.table_id = target_table_id
      self.save
    end

    # update table users and colors, this should go into table.rb
    origin_table.user = nil if origin_table.orders.existing.where( :finished => false ).empty?
    origin_table.save
    
    target_table.user = self.user
    target_table.save
  end

  def regroup
    items = self.items.existing
    n = items.size - 1
    0.upto(n-1) do |i|
      (i+1).upto(n) do |j|
        if (items[i].article_id  == items[j].article_id and
            items[i].quantity_id == items[j].quantity_id and
            items[i].options     == items[j].options and
            items[i].price       == items[j].price and
            items[i].comment     == items[j].comment and
            items[i].scribe      == items[j].scribe and
            not items[i].destroyed?
            )
          items[i].count += items[j].count
          items[i].printed_count += items[j].printed_count
          result = items[i].save
          items[j].destroy
        end
      end
    end
    self.reload
  end

  def finish
    self.finished_at = Time.now
    self.finished = true
    Item.connection.execute('UPDATE items SET preparation_count = count, delivery_count = count;')
    self.save
    self.unlink
  end

  def pay
    self.finish
    self.change_given = - (self.sum - self.payment_method_items.sum(:amount))
    self.change_given = 0 if self.change_given < 0
    self.paid = true
    self.paid_at = Time.now
    self.save
  end

  def print(what, vendor_printer=nil)
    # prepare vendor printers
    if what.include? 'tickets'
      vendor_printers = self.vendor.vendor_printers.existing
      printr = Printr.new(vendor_printers)
    else
      printr = Printr.new(vendor_printer)
    end

    printr.open

    # print
    if what.include? 'tickets'
      vendor_printers.each do |p|
        printr.print p.id, self.escpos_tickets(p.id)
      end
    end
    if what.include? 'receipt'
      if vendor_printer
        printr.print vendor_printer.id, self.escpos_receipt
        self.update_attribute :printed, true
      else
        self.update_attribute :print_pending, true
      end
    elsif what.include? 'interim_receipt'
      if vendor_printer
        printr.print vendor_printer.id, self.escpos_interim_receipt
      end
    end
    printr.close
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
    "\e@"     +  # Initialize Printer
    "\e!" + fontstyle.chr +
    "\n\n\n\n\n"

    cut =
    "\n\n\n\n\n\n" +
    "\x1D\x56\x00" +        # paper cut
    "\x1B\x70\x00\x99\x99\x0C"  # beep

    header = ''

    if vendor.ticket_display_time_order
      header += header_format_time_order % [I18n.l(Time.now + vendor.time_offset.hours, :format => :time_short), (vendor.use_order_numbers ? self.nr : 0)]
    end

    header += header_format_user_table % [self.user.login, self.table.name]

    header += header_note_format % [self.note] if self.note and not self.note.empty?
    header += "\xDF" * width + "\n"

    separate_receipt_contents = []
    normal_receipt_content = ''
      
    selected_categories = printer_id.nil? ? self.vendor.categories.existing.active : self.vendor.categories.existing.active.where(:vendor_printer_id => printer_id)
    
    selected_categories.each do |c|
      items = self.items.existing.where("count > printed_count AND category_id = #{ c.id }")
      catstring = ''
      items.each do |i|
        next if i.options.find_all_by_no_ticket(true).any?
        itemstring = ''
        itemstring += article_format % [ i.count - i.printed_count, i.article.name]
        itemstring += quantity_format % ["#{i.quantity.prefix} #{i.quantity.postfix}"] if i.quantity
        itemstring += comment_format % [i.comment] unless i.comment.empty?
        i.options.each do |po|
          itemstring += option_format % [po.name]
        end
        itemstring = Printr.sanitize(itemstring)
        itemstring += i.scribe_escpos.encode('ISO-8859-15') if i.scribe_escpos
        itemstring += Printr.sanitize(item_separator_format % [(i.price + i.options_price) * (i.count - i.printed_count)]) if vendor.ticket_item_separator
        if i.options.find_all_by_separate_ticket(true).any?
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
      output += (Printr.sanitize(header) + content + Printr.sanitize(cut)) unless content.empty?
    end
    output += (Printr.sanitize(header) + normal_receipt_content + Printr.sanitize(cut)) unless normal_receipt_content.empty?
    return '' if output == init

    logo = self.vendor.rlogo_footer ? self.vendor.rlogo_footer.encode('ISO-8859-15') : ''
    logo = "\ea\x01" + logo + "\ea\x00"
    return logo + output
  end


  def escpos_receipt
    vendor = self.vendor
    logo =
    "\e@"     +  # Initialize Printer
    "\ea\x01" +  # align center
    "\e!\x38" +  # doube tall, double wide, bold
    vendor.name + "\n"

    header = ''
    header +=
    "\e!\x01" +  # Font B
    "\ea\x01" +  # center
    "\n" + vendor.receipt_header_blurb + "\n" if vendor.receipt_header_blurb
    
    header +=
    "\ea\x00" +  # align left
    "\e!\x01" +  # Font B
    I18n.t('served_by_X_on_table_Y', :waiter => self.user.title, :table => self.table.name) + "\n"

    header += I18n.t('invoice_numer_X_at_time', :number => self.nr, :datetime => I18n.l(self.created_at + vendor.time_offset.hours, :format => :long)) if vendor.use_order_numbers

    header += "\n\n" +
    "\e!\x00" +  # Font A
    "                 #{I18n.t('activerecord.models.article.one')}   #{I18n.t('various.unit_price_abbreviation')}   #{I18n.t('various.quantity_abbreviation')}    #{I18n.t('various.total_price_abbreviation')}\n" +
    "\xc4" * 42 + "\n"

    list_of_items = ''
    self.items.existing.positioned.each do |item|
      next if item.count == 0
      list_of_options = ''
      item.options.each do |o|
        next if o.price == 0
        list_of_options += "%s %22.22s %6.2f %3u %6.2f\n" % [item.taxes.collect{|k,v| v[:l]}[0..1].join(''), "#{ I18n.t(:refund) + ' ' if item.refunded}#{ o.name }", o.price, item.count, item.refunded ? 0 : (o.price * item.count)]
      end

      label = item.quantity ? "#{ I18n.t(:refund) + ' ' if item.refunded }#{ item.quantity.prefix } #{ item.quantity.article.name }#{ ' ' unless item.quantity.postfix.empty? }#{ item.quantity.postfix }" : "#{ I18n.t(:refund) + ' ' if item.refunded }#{ item.article.name }"

      list_of_items += "%2s %21.21s %6.2f %3u %6.2f\n" % [item.taxes.collect{|k,v| v[:l]}[0..1].join(''), label, item.price, item.count, item.sum]
      list_of_items += list_of_options
    end

    sum_format =
    "                              " + "\xcd" * 12 + "\r\n" +
    "\e!\x18" + # double tall, bold
    "\ea\x02"   # align right

    sum = "#{I18n.t(:sum).upcase}:   #{I18n.t('number.currency.format.friendly_unit')} %.2f" % self.sum

    refund = self.refund_sum.zero? ? '' : ("\n#{I18n.t(:refund)}:  #{I18n.t('number.currency.format.friendly_unit')} %.2f" % self.refund_sum)

    tax_format = "\n\n" +
    "\ea\x01" +  # align center
    "\e!\x01" # Font A

    tax_header = "         #{I18n.t(:net)}  #{I18n.t('various.tax')}   #{I18n.t(:gross)}\n"

    list_of_taxes = ''
    self.taxes.each do |k,v|
      list_of_taxes += "%s: %2i%% %7.2f %7.2f %8.2f\n" % [v[:l],v[:p],v[:n], v[:t], v[:g]]
    end
    
    list_of_payment_methods = "\n"
    self.payment_method_items.each do |pm|
      list_of_payment_methods += "%20.20s %7.2f\n" % [pm.payment_method.name, pm.amount]
    end
    list_of_payment_methods += "%20.20s %7.2f\n" % [Order.human_attribute_name(:change_given), self.change_given] if self.change_given

    footer = ''
    footer = 
    "\ea\x01" +  # align center
    "\e!\x00" + # font A
    "\n" + vendor.receipt_footer_blurb + "\n" if vendor.receipt_footer_blurb

    duplicate = self.printed ? " *** DUPLICATE/COPY/REPRINT *** " : ''

    headerlogo = vendor.rlogo_header ? vendor.rlogo_header.encode!('ISO-8859-15') : Printr.sanitize(logo)
    footerlogo = vendor.rlogo_footer ? vendor.rlogo_footer.encode!('ISO-8859-15') : ''

    output = headerlogo + Printr.sanitize(header + list_of_items + sum_format + sum + refund + tax_format + tax_header + list_of_taxes + list_of_payment_methods + footer + duplicate) + "\n" + footerlogo + "\n\n\n\n\n\n" +  "\x1DV\x00\x0C" # paper cut
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
      if i.options.any? or not i.comment.empty? or i.scribe or i.price != parent_price
        d = "i#{i.id}"
      end
      options = {}
      optioncount = 0
      i.options.each do |opt|
        optioncount += 1
        options.merge! optioncount => { :id => opt.id, :n => opt.name, :p => opt.price }
      end
      if i.quantity_id
        a.merge! d => { :id => i.id, :ci => i.category_id, :ai => i.article_id, :qi => i.quantity_id, :d => d, :c => i.count, :sc => i.count, :p => i.price, :o => i.comment, :t => options, :i => i.i, :pre => i.quantity.prefix, :post => i.quantity.postfix, :n => i.article.name, :s => i.position, :h => !i.scribe.nil? }
      else
        a.merge! d => { :id => i.id, :ci => i.category_id, :ai => i.article_id, :d => d, :c => i.count, :sc => i.count, :p => i.price, :o => i.comment, :t => options, :i => i.i, :pre => '', :post => '', :n => i.article.name, :s => i.position, :h => !i.scribe.nil? }
      end
    end
    return a.to_json
  end
end
