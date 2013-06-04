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
  attr_accessible :user_id, :confirmation_count, :preparation_user_id, :delivery_user_id, :vendor_id, :company_id, :hidden_by, :price, :order_id, :scribe, :settlement_id, :cost_center_id, :statistic_category_id
  
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
  alias_attribute :cids, :customers_ids

  def separate
    return if self.count == 1 or self.refunded
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
    self.hide(-6) if self.count == 0

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
    separated_item.tax_items.update_all :cost_center_id => self.cost_center_id, :settlement_id => self.settlement_id
    self.order.calculate_totals
  end

  def scribe_bitmap
    return nil unless self.scribe
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
    write_attribute :scribe_escpos, Escper::Img.new(self.scribe_bitmap,:obj).to_s
  end

  def refund(by_user, payment_method_id)
    return if self.refunded
    unless self.cost_center and self.cost_center.no_payment_methods == true
      payment_method = PaymentMethod.where(:company_id => self.company_id, :vendor_id => self.vendor_id).find_by_id(payment_method_id)
      if payment_method
        PaymentMethodItem.create :company_id => self.company_id, :vendor_id => self.vendor_id, :order_id => self.order_id, :payment_method_id => payment_method_id, :cash => payment_method.cash, :amount => self.sum, :refunded => true, :refund_item_id => self.id, :settlement_id => self.settlement_id, :cost_center_id => self.cost_center_id, :user_id => by_user
      end
    end
    
    self.refunded = true
    self.refunded_by = by_user.id
    self.refund_sum = self.sum
    self.tax_items.existing.update_all :refunded => true
    self.calculate_totals
    self.order.calculate_totals
    
    self.settlement.calculate_totals if self.settlement
    self.unlink
  end

  def calculate_totals
    self.price = price # the JS UI doesn't send the price by default, so we get it from article or quantity
    self.category_id ||= self.article.category_id
    self.statistic_category_id ||= self.article.statistic_category_id
    self.cost_center_id = self.order.cost_center_id # for the split items function, self.order.cost_center_id is still nil
    self.option_items.update_all :count => self.count
    self.sum = full_price
    self.calculate_taxes(self.article.taxes)
    self.save
  end
  
  def calculate_taxes(tax_array)
    self.taxes = {}
    tax_sum_total = 0
    tax_array.each do |tax|
      if self.vendor.country == 'us'
        net = (self.sum).round(2)
        gro = (net * ( 1.0 + (tax.percent / 100.0))).round(2)
      else
        gro = (self.sum).round(2)
        net = (gro / ( 1.0 + ( tax.percent / 100.0 ))).round(2)
      end
      tax_sum = (gro - net).round(2)
      self.taxes[tax.id] = {:t => tax_sum, :g => gro, :n => net, :l => tax.letter, :e => tax.name, :p => tax.percent}
      
      self.save if self.new_record? # we need an id for the next step
      tax_item = TaxItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :item_id => self.id, :tax_id => tax.id, :order_id => self.order_id).first
      
      # TaxItem creation
      if tax_item
        tax_item.update_attributes :gro => gro, :net => net, :tax => tax_sum, :letter => tax.letter, :name => tax.name, :percent => tax.percent
      else
        TaxItem.create :vendor_id => self.vendor_id, :company_id => self.company_id, :item_id => self.id, :tax_id => tax.id, :order_id => self.order_id, :gro => gro, :net => net, :tax => tax_sum, :letter => tax.letter, :name => tax.name, :percent => tax.percent, :category_id => self.category_id, :statistic_category_id => self.statistic_category_id
      end
      tax_sum_total += tax_sum
    end
    self.tax_sum = tax_sum_total
    self.save
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
    write_attribute(:min_count, c) if self.min_count.nil? or c < self.min_count
  end

  def options_price
    self.option_items.sum(:price)
  end

  def full_price
    return 0 if self.price.nil? or self.count.nil?
    self.price * self.count + self.option_items.sum(:sum)
  end
  
  def price_with_options
    self.price + self.option_items.sum(:price)
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

  def hide(by_user_id)
    self.hidden = true
    self.hidden_by = by_user_id
    self.hidden_at = Time.now
    self.save
    self.unlink
    self.tax_items.where(:hidden => nil).update_all :hidden => true, :hidden_by => by_user_id, :hidden_at => Time.now
    self.option_items.where(:hidden => nil).update_all :hidden => true, :hidden_by => by_user_id, :hidden_at => Time.now
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
  
  def self.split_items(items, order)
    first_item_id = items.first[0]
    first_item = Item.find_by_id(first_item_id)
    
    parent_order = first_item.order
    split_order = parent_order.order
    
    # the following should never happen, but since moving items to an already finished order is a very touchy issue, we unlink again, just as a redundant safety measure.
    if split_order and split_order.finished
      split_order.unlink
      split_order = nil
    end
    
    if split_order.nil?
      split_order = Order.new(parent_order.attributes)
      split_order.update_attribute :nr, first_item.vendor.get_unique_model_number('order')
      parent_order.order = split_order
      split_order.order = parent_order
    end
    
    items.each do |k,v|
      item = Item.find_by_id(k)
      item.split(v['split_count'].to_i, parent_order, split_order) unless v['split_count'].to_i.zero?
    end
    
    partner_order = order.order # it seems that at this point, partner_order is still unsaved
    if order.items.existing.any?
      order.calculate_totals
      order.update_associations
    else
      order.hide(-3) 
    end
    
    if partner_order
      if partner_order.items.existing.any?
        partner_order.calculate_totals
        partner_order.update_associations
      elsif partner_order
        partner_order.hide(-3) 
      end
    end
  end

  def split(count=1, parent_order, split_order)
    partner_item = self.item
    if partner_item.nil?
      partner_item = Item.new(self.attributes) # attention: at this point, partner_item will still have the id of self. below, we call partner_item.save, and only at this point it gets the new id.
      partner_item.option_items = []
      self.option_items.existing.each do |o|
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
    partner_item.save
    partner_item.option_items.existing.each { |oi| oi.calculate_totals }
    partner_item.calculate_totals
    self.option_items.existing.each { |oi| oi.calculate_totals }
    self.save
    self.calculate_totals
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
    self.tax_items.update_all :hidden => true, :hidden_by => -4, :hidden_at => Time.now
    self.calculate_taxes([next_tax])
    self.order.calculate_totals
  end
  
  def check
    messages = []
    tests = []
    self.option_items.existing.each do |oi|
      messages << oi.check
    end
    
    item_hash_gro = 0
    item_hash_net = 0
    item_hash_tax = 0
    self.taxes.each do |k,v|
      item_hash_tax += v[:t]
      item_hash_gro += v[:g]
      item_hash_net += v[:n]
    end
    item_hash_tax = item_hash_tax.round(2)
    item_hash_gro = item_hash_gro.round(2)
    item_hash_net = item_hash_net.round(2)
    
    if self.vendor.country == 'us'
      tests[1] = (self.sum.round(2) == item_hash_net )
    else
      # TODO: This test only succeeds when there is only 1 tax attached to the item.
      tests[1] = (self.sum.round(2) == item_hash_gro )
    end
    
    tests[2] = (self.tax_sum.round(2) == item_hash_tax )
    
    if self.refunded
      #tests[3] = self.sum == 0
      tests[4] = self.tax_items.existing.where(:refunded => nil).sum(:tax) == 0
      tests[5] =  self.option_items.sum(:sum) == 0
    end
    
    unless self.hidden
      tests[6] = self.tax_items.existing.count == self.taxes.keys.count
      
      unless self.refunded
        tests[7] = self.option_items.sum(:sum).round(2) == (self.sum - self.price * self.count).round(2)
      end
    
      item_tax_sum = 0
      self.taxes.each do |k,v|
        item_tax_sum += v[:t]
      end
      
      tests[8] = self.tax_items.existing.sum(:tax).round(2) == item_tax_sum.round(2)
    end
    
    0.upto(tests.size-1).each do |i|
      messages << "Item #{ self.id }: test #{i} failed." if tests[i] == false
    end
    return messages
  end
  
end
