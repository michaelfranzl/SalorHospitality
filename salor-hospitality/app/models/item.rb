# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Item < ActiveRecord::Base
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
  has_and_belongs_to_many :options
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
  alias_attribute :i, :optionslist
  alias_attribute :cids, :customers_ids

  def separate
    return if self.count == 1
    separated_item = self.item
    if separated_item.nil?
      separated_item = Item.create(self.attributes)
      separated_item.options = self.options
      separated_item.count = 0
      separated_item.item = self
      self.item = separated_item
    end
    self.count -= 1
    self.hide(0) if self.count == 0

    separated_item.count += 1
    separated_item.save

    separated_item.calculate_totals
    self.calculate_totals
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
    self.calculate_totals
    self.order.calculate_totals
  end

  def calculate_totals
    #self.price = price
    #self.tax_percent = tax.percent
    #self.tax_id = self.tax.id if self.tax_id.nil?
    self.category_id = article.category.id
    #save
    if self.refunded
      #self.tax_sum = 0
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
    tax_array.each do |tax|
      tax_sum = (self.sum * ( tax.percent / 100.0 )).round(2)
      gro = (self.sum).round(2)
      net = (gro - tax_sum).round(2)
      self.taxes[tax.id] = {:t => tax_sum, :g => gro, :n => net, :l => tax.letter, :e => tax.name, :p => tax.percent}
      
      tax_item = TaxItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :item_id => self.id, :tax_id => tax.id, :order_id => self.order_id).first
      
      # TaxItem creation
      if tax_item
        tax_item.update_attributes :gro => gro, :net => net, :tax => tax_sum, :letter => tax.letter, :name => tax.name, :percent => tax.percent
      else
        TaxItem.create :vendor_id => self.vendor_id, :company_id => self.company_id, :item_id => self.id, :tax_id => tax.id, :order_id => self.order_id, :gro => gro, :net => net, :tax => tax_sum, :letter => tax.letter, :name => tax.name, :percent => tax.percent
      end
    end
    save
  end
  

  def update_option_items_from_ids(ids)
    ids.delete '0' # 0 is sent by JS always, otherwise surchargeslist is not sent by ajax call

    ids.each do |i|
      o = Option.find_by_id(i.to_i)
      option_item = OptionItem.create :vendor_id => o.vendor_id, :company_id => o.company_id, :option_id => o.id, :item_id => self.id, :order_id => self.order_id, :price => o.price, :name => o.name, :count => self.count, :sum => self.count * self.price, :hidden => self.hidden, :hidden_by => self.hidden_by
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
    write_attribute :count, c
    write_attribute(:max_count, c) if c > self.max_count
  end

  #def total_price
  #  self.sum
  #end

  def options_price
    self.option_items.sum(:price)
  end

  #def total_options_price
  #  self.option_items.sum(:sum)
  #end

  def full_price
    self.price * self.count + self.option_items.sum(:sum)
  end

  def optionslist
    self.options.collect{ |o| o.id }
  end

  def optionslist=(optionslist)
    optionslist.delete '0' # 0 is sent by JS always, otherwise optionslist is not defined
    self.options = []
    optionslist.each do |o|
      self.options << Option.find_by_id(o.to_i)
    end
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
    options = self.options.collect{ |o| "<br>#{ o.name } #{ number_to_currency o.price }" }.join
    usage + options
  end

  def hide(by_user_id)
    self.hidden = true
    self.hidden_by = by_user_id
    self.tax_items.update_all :hidden => true
    self.save
  end

  def unlink
    self.item = nil # self.item_id = nil does NOT work.
    self.save
  end

  def split(count)
    parent_order = self.order
    vendor = self.vendor
    split_order = parent_order.order
    if split_order.nil?
      split_order = Order.create(parent_order.attributes)
      split_order.nr = vendor.get_unique_model_number('order')
      parent_order.update_attribute :order, split_order  # make an association between parent and child
      split_order.update_attribute :order, parent_order  # ... and vice versa
    end
    partner_item = self.item
    if partner_item.nil?
      partner_item = Item.create(self.attributes)
      partner_item.options = self.options
      partner_item.count = 0
      partner_item.printed_count = 0
      self.item = partner_item # make an association between parent and child
      partner_item.item = self # ... and vice versa
    end
    partner_item.order = split_order # this is the actual moving to the new order
    
    count = self.count if count > self.count
    #  self.count > 0
      partner_item.count += count
      partner_item.printed_count += count
      self.count -= count
      self.printed_count -= count
    # end
    
    if self.count == 0
      self.hide(0)
      self.unlink
      partner_item.unlink
    end
    partner_item.calculate_totals
    self.calculate_totals
    if parent_order.items.existing.empty?
      parent_order.hide(0)
      parent_order.unlink
    else
      parent_order.calculate_totals
    end
    split_order.calculate_totals
  end
  
  def compose_option_names_without_price
    options.collect{ |o| "<br>#{ o.name }" }.join
  end
  
end
