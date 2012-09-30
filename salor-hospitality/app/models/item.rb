# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Item < ActiveRecord::Base
  attr_accessible :position, :comment, :price, :article_id, :quantity_id, :category_id, :count, :printed_count, :usage, :hidden, :customers_ids
  attr_accessible :s, :o, :p, :ai, :qi, :ci, :c, :pc, :u, :x, :cids
  attr_accessible :preparation_user_id, :delivery_user_id, :vendor_id, :company_id, :hidden_by, :price, :order_id
  
  include Scope
  belongs_to :order
  belongs_to :article
  belongs_to :quantity
  belongs_to :item
  belongs_to :tax
  belongs_to :vendor
  belongs_to :company
  belongs_to :category
  belongs_to :settlement
  belongs_to :cost_center
  has_many :tax_items
  has_many :option_items
  validates_presence_of :count, :article_id

  serialize :taxes

  alias_attribute :s, :position
  alias_attribute :o, :comment
  alias_attribute :p, :price
  alias_attribute :ai, :article_id
  alias_attribute :qi, :quantity_id
  alias_attribute :ci, :category_id
  alias_attribute :c, :count
  alias_attribute :pc, :printed_count
  alias_attribute :u, :usage
  alias_attribute :x, :hidden
  #alias_attribute :i, :optionslist
  alias_attribute :cids, :customers_ids

  def separate
    return if self.count == 1
    separated_item = self.item
    if separated_item.nil?
      separated_item = Item.create(self.attributes)
      separated_item.option_items = []
      self.option_items.each do |option_item|
        separated_option_item = OptionItem.create option_item.attributes
        separated_item.option_items << separated_option_item
      end        
      separated_item.count = 0
      separated_item.item = self
      self.item = separated_item
    end
    self.count -= 1
    self.hide(0) if self.count == 0

    separated_item.count += 1
    separated_item.save
    separated_item.option_items.each do |o| 
      o.calculate_totals
    end
    self.save
    self.option_items.each do |o| 
      o.calculate_totals
    end
    separated_item.calculate_totals
    self.calculate_totals
    self.order.calculate_totals
  end

  def scribe_bitmap
    canvas = Magick::Image.new(512, 128)
    gc = Magick::Draw.new
    gc.stroke('black')
    gc.stroke_width(5)
    gc.fill('white')
    gc.fill_opacity(0)
    gc.stroke_antialias(false)
    gc.stroke_linejoin('round')
    gc.translate(-10,-39)
    gc.scale(1.11,0.68)
    gc.path(self.scribe)
    gc.draw(canvas)
    return canvas
  end

  def scribe=(scribe)
    return if scribe.nil?
    write_attribute :scribe, scribe
    write_attribute :scribe_escpos, Escper::Image.new(self.scribe_bitmap,:object).to_s
  end

  def refund(by_user)
    self.refunded = true
    self.refunded_by = by_user.id
    self.refund_sum = self.sum
    self.tax_items.update_all :hidden => true, :hidden_by => -5
    self.option_items.update_all :sum => 0
    self.calculate_totals
    self.order.calculate_totals
  end

  def calculate_totals
    self.price = price # the JS UI doesn't send the price by default, so we get it from article or quantity
    self.category_id = self.article.category.id
    if self.refunded
      self.tax_sum = 0
      self.sum = 0
      self.taxes = {}
    else
      self.sum = full_price.round(2)
      self.calculate_taxes(self.article.taxes)
    end
    save
  end
  
  def calculate_taxes(tax_array)
    self.taxes = {}
    tax_sum_total = 0
    tax_array.each do |tax|
      gro = (self.sum).round(2)
      net = (gro / ( 1.0 + ( tax.percent / 100.0 ))).round(2)
      tax_sum = (gro - net).round(2)
      self.taxes[tax.id] = {:t => tax_sum, :g => gro, :n => net, :l => tax.letter, :e => tax.name, :p => tax.percent}
      
      self.save if self.new_record? # we need an id for the next step
      tax_item = TaxItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :item_id => self.id, :tax_id => tax.id, :order_id => self.order_id).first
      
      # TaxItem creation
      if tax_item
        tax_item.update_attributes :gro => gro, :net => net, :tax => tax_sum, :letter => tax.letter, :name => tax.name, :percent => tax.percent
      else
        TaxItem.create :vendor_id => self.vendor_id, :company_id => self.company_id, :item_id => self.id, :tax_id => tax.id, :order_id => self.order_id, :gro => gro, :net => net, :tax => tax_sum, :letter => tax.letter, :name => tax.name, :percent => tax.percent
      end
      tax_sum_total += tax_sum
    end
    self.tax_sum = tax_sum_total
    save
  end
  

  def create_option_items_from_ids(ids)
    return if ids.nil?
    ids.delete '0' # 0 is sent by JS always, otherwise surchargeslist is not sent by ajax call
    ids.each do |i|
      o = Option.find_by_id(i.to_i)
      option_item = OptionItem.create :vendor_id => o.vendor_id, :company_id => o.company_id, :option_id => o.id, :item_id => self.id, :order_id => self.order_id, :price => o.price, :name => o.name, :count => self.count, :sum => self.count * o.price, :hidden => self.hidden, :hidden_by => self.hidden_by, :no_ticket => o.no_ticket, :separate_ticket => o.separate_ticket
    end
  end

  def price
    p = read_attribute :price
    if p.nil?
      p = self.article.price if self.article
      p = self.quantity.price if self.quantity
    end
    p
  end

  def count=(count)
    c = count.to_i
    write_attribute(:count, c)
    write_attribute(:max_count, c) if c > self.max_count
  end

  def options_price
    self.option_items.sum(:price)
  end

  def full_price
    self.price * self.count + self.option_items.sum(:sum)
  end

  def optionslist
    self.option_items.collect{ |oi| oi.option_id }
  end

  def usage
    u = read_attribute :usage
    return u if u
    u = self.quantity.usage if self.quantity
    return u if u
    return self.article.usage if self.article
  end
  
  def formatted_comment
    self.comment ? '<br/>' + self.comment : ''
  end

  def label
    if self.quantity
      "#{ self.quantity.prefix } #{ self.article.name } #{ self.quantity.postfix }"
    else
      self.article.name
    end
  end

  def optionsnames
    usage = self.usage == 1 ? "<br>#{ I18n.t 'articles.new.takeaway' }" : ''
    options = self.option_items.collect{ |o| "<br>#{ o.name } #{ number_to_currency o.price }" }.join
    usage + options
  end

  def hide(by_user_id)
    self.hidden = true
    self.hidden_by = by_user_id
    self.save
    self.unlink
    self.tax_items.where(:hidden => nil).update_all :hidden => true, :hidden_by => by_user_id
    self.option_items.where(:hidden => nil).update_all :hidden => true, :hidden_by => by_user_id
  end

  def unlink
    partner_item = self.item
    if partner_item
      partner_item.item = nil
      partner_item.save
    end
    self.item = nil
    self.save
  end

  def split(count=1)
    parent_order = self.order
    split_order = parent_order.order
    if split_order.nil?
      split_order = Order.new(parent_order.attributes)
      split_order.nr = self.vendor.get_unique_model_number('order')
      parent_order.order = split_order
      split_order.order = parent_order
    end
    partner_item = self.item
    if partner_item.nil?
      partner_item = Item.new(self.attributes) # attention: at this point, partner_item will still have the id of self. below, we call partner_item.save, and only at this point it gets the new id.
      partner_item.option_items = []
      self.option_items.each do |o|
        partner_option_item = OptionItem.create o.attributes # warning: at this point, the OptionItem still has the wrong count. calling OptionItem.calculate_totals below will fix that.
        partner_item.option_items << partner_option_item
      end
      partner_item.count = 0
      partner_item.printed_count = 0
      self.item = partner_item
      partner_item.item = self
      partner_item.order = split_order 
    end
    count = self.count if count > self.count # do not decrement into negative numbers
    partner_item.count += count
    partner_item.printed_count += count
    self.count -= count
    self.printed_count -= count
    self.hide(-3) if self.count.zero?
    partner_item.save # only a direct method of self has access to unsaved object changes. since we call OptionItem.calculate_totals below, this methods would not have access to those changes if we wouldn't save. therefore, we must save here.
    partner_item.option_items.each do |o|
      o.calculate_totals
    end
    self.save
    self.option_items.each do |o| 
      o.calculate_totals
    end
    partner_item.calculate_totals
    self.calculate_totals
    if parent_order.items.existing.empty?
      parent_order.hide(-3)
    else
      parent_order.calculate_totals
    end
    split_order.calculate_totals
  end
  
  def compose_option_names_without_price
    self.option_items.collect{ |o| "#{ o.name }" }.join("<br />")
  end
  
  def rotate_tax
    tax_ids = self.vendor.taxes.existing.collect { |t| t.id }
    current_item_tax = self.vendor.taxes.find_by_id(self.taxes.keys.first)
    current_tax_id_index = tax_ids.index current_item_tax.id
    next_tax_id = tax_ids.rotate[current_tax_id_index]
    next_tax = self.vendor.taxes.find_by_id(next_tax_id)
    self.tax_items.update_all :hidden => true, :hidden_by => -4
    self.calculate_taxes([next_tax])
    self.order.calculate_totals
  end
  
  def check
    self.option_items.existing.each do |o|
      o.check
    end
    item_sum = self.sum
    item_tax_sum = self.tax_sum
    item_hash_gro = 0
    item_hash_tax = 0
    self.taxes.each do |k,v|
      item_hash_tax += v[:t]
      item_hash_gro = v[:g]
    end
    item_hash_tax = item_hash_tax.round(2)
    item_hash_gro = item_hash_gro.round(2)
    test1 = (item_sum == item_hash_gro ) && (item_tax_sum == item_hash_tax )
    raise "Item test1 failed for id #{id}" unless test1
    
    if self.refunded
      test2 = item_sum == 0
      raise "Item test2 failed for id #{id}" unless test2
      test3 = self.tax_items.existing.sum(:tax).round(2) == 0
      raise "Item test3 failed for id #{id}" unless test3
      test3b =  self.option_items.sum(:sum).round(2) == 0
      raise "Item test3b failed for id #{id}" unless test3b
    end
    
    unless self.hidden
      test3a = self.tax_items.existing.count == self.taxes.keys.count
      raise "Item test3a failed for id #{id}" unless test3a
      test4 = self.option_items.sum(:sum).round(2) == (self.sum - self.price * self.count).round(2)
      raise "Item test4 failed for id #{id}" unless test4
    
      item_tax_sum = 0
      self.taxes.each do |k,v|
        item_tax_sum += v[:t]
      end
      test5 = self.tax_items.existing.sum(:tax).round(2) == item_tax_sum.round(2)
      raise "Item test5 failed for id #{id}" unless test5
    end
  end
  
end
