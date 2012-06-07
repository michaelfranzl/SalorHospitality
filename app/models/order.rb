# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
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
  belongs_to :room
  has_many :items, :dependent => :destroy
  has_many :payment_method_items
  has_one :order

  after_save :hide_items

  validates_presence_of :user_id

  accepts_nested_attributes_for :items, :allow_destroy => true #, :reject_if => proc { |attrs| attrs['count'] == '0' || ( attrs['article_id'] == '' && attrs['quantity_id'] == '') }

  def set_nr
    if self.nr.nil?
      self.update_attribute :nr, self.vendor.get_unique_order_number
    end
  end

  def self.create_from_params(params, vendor, user)
    order = Order.new params[:model]
    order.user = user
    order.cost_center = vendor.cost_centers.existing.active.first
    order.vendor = vendor
    order.company = vendor.company
    params[:items].to_a.each do |item_params|
      new_item = Item.new(item_params[1])
      new_item.cost_center = order.cost_center
      new_item.calculate_totals
      order.items << new_item
    end
    order.save
    return order
  end

  def update_from_params(params)
    self.update_attributes params[:model]
    if params[:payment_methods] then
      self.payment_methods.clear
      params[:payment_methods].each do |pm|
        self.payment_methods << PaymentMethod.new(pm)
      end
    end
    params[:items].to_a.each do |item_params|
      item_id = item_params[1][:id]
      if item_id
        item_params[1].delete(:id)
        item = Item.find_by_id(item_id)
        item.update_attributes(item_params[1])
        item.calculate_totals
      else
        new_item = Item.new(item_params[1])
        new_item.cost_center = self.cost_center
        new_item.calculate_totals
        self.items << new_item
        self.save
      end
    end
  end

  def update_associations(user)
    self.table.user = user
    self.table.save
    self.user = user
    self.items.where( :user_id => nil, :preparation_user_id => nil, :delivery_user_id => nil ).each do |i|
      i.update_attributes :user_id => user.id, :vendor_id => self.vendor.id, :company_id => self.company.id, :preparation_user_id => i.category.preparation_user_id, :delivery_user_id => user.id
    end
    save
  end

  def calculate_totals
    self.sum = items.existing.sum(:sum)
    self.refund_sum = items.existing.sum(:refund_sum)
    self.tax_sum = items.existing.sum(:tax_sum)
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
  end

  def hide_items
    if self.hidden
      self.items.update_all :hidden => true
    end
  end

  # def customer_set=(h)
  #   return if h.nil?
  #   h.each do |cus|
  #     Order.connection.execute("DELETE FROM customers_orders where customer_id = #{cus} and order_id = #{self.id}")
  #     Order.connection.execute("INSERT INTO customers_orders (customer_id,order_id) VALUES (#{cus}, #{self.id})")
  #   end
  # end

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
      write_attribute :table_id, target_table_id
    end
    self.save

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
        Item.transaction do
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
            raise "Couldn't save item during grouping. Oops!" if not result
            items[j].destroy
          end
        end
      end
    end
    self.reload
  end

  def finish
    self.updated_at = Time.now
    self.finished = true
    self.change_given = - (self.sum - self.payment_method_items.sum(:amount))
    Item.connection.execute('UPDATE items SET preparation_count = count, delivery_count = count;')
    save
    unlink
  end

  def pay
    self.finish
    self.update_attribute :paid, true
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
    if what.include? 'invoice'
      if vendor_printer
        printr.print vendor_printer.id, self.escpos_invoice
        self.update_attribute :printed, true
      else
        self.update_attribute :print_pending, true
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
    "\n\n\n"

    cut =
    "\n\n\n\n" +
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
    self.vendor.categories.existing.active.where(:vendor_printer_id => printer_id).each do |c|
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


  def escpos_invoice
    vendor = self.vendor
    logo =
    "\e@"     +  # Initialize Printer
    "\ea\x01" +  # align center
    "\e!\x38" +  # doube tall, double wide, bold
    vendor.name + "\n"

    header =
    "\e!\x01" +  # Font B
    "\ea\x01" +  # center
    "\n" + vendor.invoice_subtitle +
    "\n" + vendor.address +
    "\n" + vendor.revenue_service_tax_number + "\n" +
    "\ea\x00" +  # align left
    "\e!\x01" +  # Font B
    I18n.t('served_by_X_on_table_Y', :waiter => self.user.title, :table => self.table.name) + "\n"

    header += I18n.t('invoice_numer_X_at_time', :number => self.nr, :datetime => I18n.l(self.created_at + vendor.time_offset.hours, :format => :long)) if vendor.use_order_numbers

    header += "\n\n" +
    "\e!\x00" +  # Font A
    "                  Artikel  EP     Stk   GP\n" +
    "------------------------------------------\n"

    sum_taxes = Hash.new
    vendor.taxes.existing.each { |t| sum_taxes[t.id] = 0 }
    subtotal = 0
    list_of_items = ''
    self.items.existing.positioned.each do |item|
      next if item.count == 0
      list_of_options = ''
      item.options.each do |o|
        next if o.price == 0
        list_of_options += "%s %22.22s %6.2f %3u %6.2f\n" % [item.tax.letter, "#{ I18n.t(:storno) + ' ' if item.refunded}#{ o.name }", o.price, item.count, item.refunded ? 0 : (o.price * item.count)]
      end

      sum_taxes[item.tax_id] += item.sum

      label = item.quantity ? "#{ I18n.t(:storno) + ' ' if item.refunded }#{ item.quantity.prefix } #{ item.quantity.article.name }#{ ' ' unless item.quantity.postfix.empty? }#{ item.quantity.postfix }" : "#{ I18n.t(:storno) + ' ' if item.refunded }#{ item.article.name }"

      list_of_items += "%s %22.22s %6.2f %3u %6.2f\n" % [item.tax.letter, label, item.price, item.count, item.sum]
      list_of_items += list_of_options
    end

    sum_format =
    "                               -----------\r\n" +
    "\e!\x18" + # double tall, bold
    "\ea\x02"   # align right

    sum = "SUMME:   EUR %.2f" % self.sum

    refund = self.refund_sum.zero? ? '' : ("\nSTORNO:  EUR %.2f" % self.refund_sum)

    tax_format = "\n\n" +
    "\ea\x01" +  # align center
    "\e!\x01" # Font A

    tax_header = "          netto     USt.  brutto\n"

    list_of_taxes = ''
    vendor.taxes.existing.each do |tax|
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
    "\n" + vendor.invoice_slogan1 + "\n" +
    "\e!\x08" + # emphasized
    "\n" + vendor.invoice_slogan2 + "\n" +
    vendor.internet_address + "\n"

    duplicate = self.printed ? " *** DUPLICATE/COPY/REPRINT *** " : ''

    footerlogo = vendor.rlogo_footer ? vendor.rlogo_footer.encode!('ISO-8859-15') : ''
    headerlogo = vendor.rlogo_header ? vendor.rlogo_header.encode!('ISO-8859-15') : Printr.sanitize(logo)

    output = headerlogo + Printr.sanitize(header + list_of_items + sum_format + sum + refund + tax_format + tax_header + list_of_taxes + footer + duplicate) + footerlogo + "\n\n\n\n\n\n" +  "\x1DV\x00\x0C" # paper cut
  end

  def items_to_json
    a = {}
    self.items.existing.positioned.reverse.each do |i|
      if i.quantity_id
        d = "q#{i.quantity_id}"
      else
        d = "a#{i.article_id}"
      end
      if i.options.any? or not i.comment.empty? or i.scribe
        d = "i#{i.id}"
      end
      options = {}
      optioncount = 0
      i.options.each do |opt|
        optioncount += 1
        options.merge! optioncount => { :id => opt.id, :n => opt.name, :p => opt.price }
      end
      if i.quantity_id
        a.merge! d => { :id => i.id, :ci => i.category_id, :ai => i.article_id, :qi => i.quantity_id, :d => d, :c => i.count, :sc => i.count, :p => i.price, :o => i.comment, :t => options, :i => i.i, :pre => i.quantity.prefix, :post => i.quantity.postfix, :n => i.article.name, :s => i.position }
      else
        a.merge! d => { :id => i.id, :ci => i.category_id, :ai => i.article_id, :d => d, :c => i.count, :sc => i.count, :p => i.price, :o => i.comment, :t => options, :i => i.i, :pre => '', :post => '', :n => i.article.name, :s => i.position }
      end
    end
    return a.to_json
  end
end
