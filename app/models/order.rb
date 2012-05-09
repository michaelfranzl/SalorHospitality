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
  belongs_to :tax
  has_many :items, :dependent => :destroy
  has_one :order
  has_and_belongs_to_many :customers

  #after_save :set_customers_up
  after_save :hide_items

  validates_presence_of :user_id

  accepts_nested_attributes_for :items, :allow_destroy => true #, :reject_if => proc { |attrs| attrs['count'] == '0' || ( attrs['article_id'] == '' && attrs['quantity_id'] == '') }

  def calculate_totals
    self.sum = items.existing.sum(:sum)
    self.refund_sum = items.existing.sum(:refund_sum)
    self.tax_sum = items.existing.sum(:tax_sum)
    save
  end

  def hide(by_user_id)
    self.hidden = true
    self.hidden_by = by_user_id
    save
  end

  def hide_items
    if self.hidden
      self.items.update_all :hidden => true
    end
  end

  def customer_set=(h)
    @customers_hash = h
  end

  def set_customers_up
    return if @customers_hash.nil?
    @customers_hash.each do |cus|
      Order.connection.execute("DELETE FROM customers_orders where customer_id = #{cus["id"]} and order_id = #{self.id}")
      Order.connection.execute("INSERT INTO customers_orders (customer_id,order_id) VALUES (#{cus["id"]}, #{self.id})")
    end
  end

  def unlink
    self.items.update_all :item_id => nil
    self.update_attribute :order_id, nil
    self.reload
    parent_order = self.order
    if parent_order
      parent_order.items.update_all :item_id => nil
      parent_order.update_attribute :order_id, nil
    end
  end

  def move(target_table_id)
    return if self.table_id == target_table_id
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
              items[i].usage       == items[j].usage and
              items[i].price       == items[j].price and
              items[i].comment     == items[j].comment and
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
    if nr and nr > vendor.largest_order_number
      vendor.update_attribute :largest_order_number, nr 
    end
    self.created_at = Time.now
    self.finished = true
    self.calculate_totals
    unlink
  end

  def print_tickets
    vendor_printers = self.vendor.vendor_printers.existing
    printr = Printr.new(vendor_printers)
    printr.open
    vendor_printers.each do |p|
      printr.print p.id, self.escpos_tickets(p.id)
    end
    printr.close
  end

  def print_invoice(vendor_printer)
    printr = Printr.new(vendor_printer)
    printr.open
    printr.print vendor_printer.id, self.escpos_invoice
    printr.close
  end

  def escpos_tickets(printer_id)
    vendor = self.vendor
    init =
    "\e@"     +  # Initialize Printer
    "\e!\x38" +  # doube tall, double wide, bold
    "\n\n"

    cut =
    "\n\n\n\n" +
    "\x1D\x56\x00" +        # paper cut
    "\x1B\x70\x00\x99\x99\x0C"  # beep

    header = ''
    header +=
    "%-14.14s #%5i\n%-12.12s %8s\n" % [I18n.l(Time.now + vendor.time_offset.hours, :format => :time_short), (vendor.use_order_numbers ? self.nr : 0), self.user.login, self.table.name]
    header += "%20.20s\n" % [self.note] if self.note and not self.note.empty?
    header += "=====================\n"

    separate_receipt_contents = []
    normal_receipt_content = ''
    self.vendor.categories.existing.active.where(:vendor_printer_id => printer_id).each do |c|
      items = self.items.existing.where("count > printed_count AND category_id = #{ c.id }")
      catstring = ''
      items.each do |i|
        itemstring = ''
        itemstring += "%i %-18.18s\n" % [ i.count - i.printed_count, i.article.name]
        itemstring += " > %-17.17s\n" % ["#{i.quantity.prefix} #{i.quantity.postfix}"] if i.quantity
        itemstring += " > %-17.17s\n" % I18n.t('articles.new.takeaway') if i.usage == -1
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
    output = '' if output == init
    return output
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
    "\n" + vendor.invoice_subtitle + "\n" +
    "\n" + vendor.address + "\n\n" +
    vendor.revenue_service_tax_number + "\n\n" +

    "\ea\x00" +  # align left
    "\e!\x01" +  # Font B

    I18n.t('served_by_X_on_table_Y', :waiter => order.user.title, :table => order.table.name) + "\n"

    header += I18n.t('invoice_numer_X_at_time', :number => order.nr, :datetime => I18n.l(order.created_at + vendor.time_offset.hours, :format => :long)) if vendor.use_order_numbers

    header += "\n\n" +

    "\e!\x00" +  # Font A
    "                  Artikel  EP     Stk   GP\n" +
    "------------------------------------------\n" +

    sum_taxes = Hash.new
    @current_vendor.taxes.existing.each { |t| sum_taxes[t.id] = 0 }
    subtotal = 0
    list_of_items = ''
    order.items.existing.positioned.each do |item|
      next if item.count == 0
      list_of_options = ''
      item.options.each do |o|
        next if o.price == 0
        list_of_options += "%s %22.22s %6.2f %3u %6.2f\n" % [item.tax.letter, "#{ I18n.t(:storno) + ' ' if item.refunded}#{ o.name }", o.price, item.count, item.refunded ? 0 : (o.price * item.count)]
      end

      sum_taxes[item.tax.id] += item.sum

      label = item.quantity ? "#{ I18n.t(:storno) + ' ' if item.refunded }#{ item.quantity.prefix } #{ item.quantity.article.name }#{ ' ' unless item.quantity.postfix.empty? }#{ item.quantity.postfix }" : "#{ I18n.t(:storno) + ' ' if item.refunded }#{ item.article.name }"

      list_of_items += "%s %22.22s %6.2f %3u %6.2f\n" % [item.tax.letter, label, item.price, item.count, item.sum]
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
      #next if sum_taxes[tax.id] == 0
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
    vendor.internet_address + "\n\n\n\n\n\n\n" + 
    "\x1DV\x00\x0C" # paper cut

    logo = vendor.rlogo_header ? vendor.rlogo_header.encode!('ISO-8859-15') : Base.sanitize_escpos(logo)
    output = logo + Base.sanitize_escpos(header + list_of_items + sum_format + sum + refund + tax_format + tax_header + list_of_taxes + footer)
  end

  def items_to_json
    a = {}
    self.items.existing.positioned.reverse.each do |i|
      if i.quantity_id
        d = "q#{i.quantity_id}"
      else
        d = "a#{i.article_id}"
      end
      if i.options.any?
        d = "i#{i.id}"
      end
      options = {}
      optioncount = 0
      i.options.each do |opt|
        optioncount += 1
        options.merge! optioncount => { :id => opt.id, :n => opt.name, :p => opt.price }
      end
      if i.quantity_id
        a.merge! d => { :id => i.id, :ci => i.category.id, :ai => i.article_id, :qi => i.quantity_id, :d => d, :c => i.count, :sc => i.count, :p => i.price, :o => i.comment, :u => i.usage, :t => options, :i => i.i, :pre => i.quantity.prefix, :post => i.quantity.postfix, :n => i.article.name, :s => i.position }
      else
        a.merge! d => { :id => i.id, :ci => i.category.id, :ai => i.article_id, :d => d, :c => i.count, :sc => i.count, :p => i.price, :o => i.comment, :u => i.usage, :t => options, :i => i.i, :pre => '', :post => '', :n => i.article.name, :s => i.position }
      end
    end
    return a.to_json
  end
end
