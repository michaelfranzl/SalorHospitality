# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Item < ActiveRecord::Base
  #attr_accessible :position, :comment, :price, :article_id, :quantity_id, :category_id, :count, :printed_count, :usage, :hidden, :customers_ids
  #attr_accessible :s, :o, :p, :ai, :qi, :ci, :c, :pc, :u, :x, :cids
  #attr_accessible :user_id, :confirmation_count, :preparation_user_id, :delivery_user_id, :vendor_id, :company_id, :hidden_by, :price, :order_id, :scribe, :settlement_id, :cost_center_id, :statistic_category_id
  
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
  
  def gross
    if self.vendor.country == "us"
      self.sum + self.tax_sum
    else
      self.sum
    end
  end

  def calculate_totals
    self.price = self.price # assign the setter the getter value. The JS UI doesn't send the price by default, so we get it from article or quantity
    self.category ||= self.article.category
    self.statistic_category_id ||= self.article.statistic_category_id
    self.position_category ||= self.category.position
    self.cost_center_id = self.order.cost_center_id # for the split items function, self.order.cost_center_id is still nil
    self.option_items.update_all :count => self.count
    self.sum = self.full_price
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
      self.taxes[tax.id] = {
        :t => tax_sum,
        :g => gro,
        :n => net,
        :l => tax.letter,
        :e => tax.name,
        :p => tax.percent
      }
      tax_sum_total += tax_sum
    end
    self.tax_sum = tax_sum_total
    self.save
  end
  
  def create_tax_items
    self.taxes.each do |tax_id, val|
      gro = val[:g]
      net = val[:n]
      tax = val[:t]
      letter = val[:l]
      percent = val[:p]
      name = val[:e]
      
      ti = TaxItem.new
      ti.vendor_id = self.vendor_id
      ti.company_id = self.company_id
      ti.item_id = self.id
      ti.tax_id = tax_id
      ti.order_id = self.order_id
      ti.gro = gro
      ti.net = net
      ti.tax = tax
      ti.letter = letter
      ti.name = name
      ti.percent = percent
      ti.category_id = self.category_id
      ti.statistic_category_id = self.statistic_category_id
      ti.cost_center_id = self.order.cost_center_id
      ti.settlement_id = self.settlement_id
      ti.save!
    end
  end
  

  def create_option_items_from_ids(ids)
    return if ids.nil?
    ids.delete '0' # 0 is sent by JS always, otherwise surchargeslist is not sent by ajax call
    ids.each do |i|
      o = Option.find_by_id(i.to_i)
      option_item = OptionItem.create(
        :vendor_id => o.vendor_id,
        :company_id => o.company_id,
        :option_id => o.id,
        :item_id => self.id,
        :order_id => self.order_id,
        :price => o.price,
        :name => o.name,
        :count => self.count,
        :sum => self.count * o.price,
        :hidden => self.hidden,
        :hidden_by => self.hidden_by,
        :no_ticket => o.no_ticket,
        :separate_ticket => o.separate_ticket
      )
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
    write_attribute(:printed_count, c) if self.count < self.printed_count
  end

  def options_price
    self.option_items.sum(:price)
  end

  def full_price
    return 0 if self.price.nil? or self.count.nil?
    return self.price * self.count + self.option_items.sum(:sum)
    # returns net for USA, gross for every other country
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
    self.tax_items.each do |ti|
      ti.hide(by_user_id)
    end

    self.option_items.each do |oi|
      oi.hide(by_user_id)
    end
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
  
  def self.split_items(items)
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
      split_order = Order.new
      split_order.table_id = parent_order.table_id
      split_order.user_id = parent_order.user_id
      split_order.company_id = parent_order.company_id
      split_order.vendor_id = parent_order.vendor_id
      split_order.nr = parent_order.vendor.get_unique_model_number('order')
      parent_order.order = split_order
      split_order.order = parent_order
    end
    
    items.each do |k,v|
      item = Item.find_by_id(k)
      item.split(v['split_count'].to_i, parent_order, split_order) unless v['split_count'].to_i.zero?
    end
    
    if parent_order.items.existing.any?
      parent_order.calculate_totals
    else
      parent_order.hide(-3) 
    end
    
    split_order.calculate_totals
  end

  def split(count=1, parent_order, split_order)
    partner_item = self.item
    if partner_item.nil?
      partner_item = Item.new
      partner_item.count = self.count
      partner_item.article_id = self.article_id
      partner_item.quantity_id = self.quantity_id
      partner_item.price = self.price
      partner_item.printed_count = self.printed_count
      partner_item.company_id = self.company_id
      partner_item.vendor_id = self.vendor_id
      partner_item.category_id = self.category_id
      partner_item.tax_percent = self.tax_percent
      partner_item.statistic_category_id = self.statistic_category_id
      partner_item.price_changed = self.price_changed
      partner_item.price_changed_by = self.price_changed_by
      partner_item.position_category = self.position_category
      partner_item.option_items = []
      self.option_items.existing.each do |o|
        partner_option_item = OptionItem.new
        partner_option_item.option_id = o.option_id
        partner_option_item.vendor_id = o.vendor_id
        partner_option_item.company_id = o.company_id
        partner_option_item.price = o.price
        partner_option_item.name = o.name
        partner_option_item.count = o.count
        partner_option_item.no_ticket = o.no_ticket
        partner_option_item.separate_ticket = o.separate_ticket
        partner_option_item.order = split_order
        partner_item.option_items << partner_option_item
      end
      partner_item.count = 0
      partner_item.printed_count = 0
      partner_item.max_count = 0
      self.item = partner_item
      partner_item.item = self
      partner_item.order = split_order 
    end
    count = self.count if count > self.count # do not decrement into negative numbers
    partner_item.count += count
    partner_item.printed_count = partner_item.count
    self.count -= count
    self.printed_count = self.count
    self.max_count = self.count
    self.hide(-3) if self.count.zero?
    partner_item.save
    partner_item.option_items.existing.each { |oi| oi.calculate_totals }
    partner_item.calculate_totals
    self.save
    unless self.hidden
      self.option_items.existing.each { |oi| oi.calculate_totals }
      self.calculate_totals
    end
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
    self.calculate_taxes([next_tax])
    self.order.calculate_totals
  end
  
  def check
    @found = nil
    @tests = {
      self.id => {
                :id => self.id,
                :tests => [],
                :option_items => [],
                :tax_items => [],
                }
    }
    
    self.option_items.existing.each do |oi|
      option_item_result, @found = oi.check
      @tests[self.id][:option_items] << option_item_result if @found
    end
    
    # calculate sums from the serialized tax hash of the item, to be used later
    item_hash_gro_sum = 0
    item_hash_net_sum = 0
    item_hash_tax_sum = 0
    self.taxes.each do |k,v|
      item_hash_tax_sum += v[:t]
      item_hash_gro_sum += v[:g]
      item_hash_net_sum += v[:n]
    end
    item_hash_gro_sum = item_hash_gro_sum.round(2)
    item_hash_net_sum = item_hash_net_sum.round(2)
    item_hash_tax_sum = item_hash_tax_sum.round(2)
    
    if self.refunded
      perform_test({
                :should => 0,
                :actual => self.sum,
                :msg => "A refunded Item should have the price of zero",
                :type => :itemRefundZero,
                })
    else
      perform_test({
                :should => (self.price * self.count + self.option_items.existing.sum(:sum)).round(2),
                :actual => self.sum,
                :msg => "An Item should have the correct sum",
                :type => :itemSumCorrect,
                })
    end
    
    # at this point, self.sum is correct, and can be used in checking TaxItems
    
    self.tax_items.existing.each do |ti|
      tax_item_result, found = ti.check
      @tests[self.id][:tax_items] << tax_item_result if found
    end
    
    # at this point, gro, net and tax of TaxItems are correct, and can be used to validate the hash keys here
    
    perform_test({
              :should => self.tax_items.existing.sum(:tax).round(2),
              :actual => item_hash_tax_sum,
              :msg => "The hashed tax attribute should be the sum of all existing TaxItem tax attributes",
              :type => :itemHashTaxIsSumOfTaxItems,
              })
    
    perform_test({
              :should => self.tax_items.existing.sum(:gro).round(2),
              :actual => item_hash_gro_sum,
              :msg => "The hashed gro attribute should be the sum of all existing TaxItem gro attributes",
              :type => :itemHashGroIsSumOfTaxItems,
              })
    
    perform_test({
              :should => self.tax_items.existing.sum(:net).round(2),
              :actual => item_hash_net_sum,
              :msg => "The hashed net attribute should be the sum of all existing TaxItem net attributes",
              :type => :itemHashNetIsSumOfTaxItems,
              })
    
    perform_test({
              :should => (item_hash_gro_sum - item_hash_net_sum).round(2),
              :actual => item_hash_tax_sum,
              :msg => "The hashed tax attribute should be hashed gro minus hashed net #{ item_hash_gro_sum } - #{ item_hash_net_sum }",
              :type => :itemHashTaxIsHashGroMinusHashNet,
              })
    
    # at this point, the hashed values gro, net and tax are validated with TaxItems, hashed tax is even double checked
    
    # check the cached Item attributes sum and tax_sum with the valid hash sums
    
    perform_test({
              :should => item_hash_tax_sum,
              :actual => self.tax_sum,
              :msg => "The tax_sum attribute should match the hashed tax attribute",
              :type => :itemTaxSumMatchesHashedTax,
              })
    
    if self.vendor.country == 'us'
      # this is redundant testing, because we already know that self.sum is correct. we do it anyway.
      perform_test({
                :should => item_hash_net_sum,
                :actual => self.sum,
                :msg => "The sum attribute should match the hashed net attribute",
                :type => :itemSumMatchesHashedNet,
                })

    else
      perform_test({
                :should => item_hash_gro_sum,
                :actual => self.sum,
                :msg => "The sum attribute should match the hashed gro attribute",
                :type => :itemSumMatchesHashedGro,
                })
    end
    
    perform_test({
          :should => self.tax_items.existing.count,
          :actual => self.taxes.keys.count,
          :msg => "An Item should have the same number of TaxItems as there are keys in the taxes attribute",
          :type => :itemTaxItemsCountCorrect,
          })
    
    perform_test({
          :should => [self.order.id, self.order.cost_center_id, self.order.settlement_id],
          :actual => [self.order_id, self.cost_center_id, self.settlement_id],
          :msg => "An Item should have the same belongs_to attributes as the Order",
          :type => :itemBelongsToCorrect,
          })
    
    perform_test({
          :should => [self.order.hidden, self.order.hidden_at, self.order.hidden_by],
          :actual => [self.hidden, self.hidden_at, self.hidden_by],
          :msg => "An Item should have the same hidden attributes as the Order",
          :type => :itemHiddenCorrect,
          })
   
    puts "\n *** WARNING: Item is deleted, tests are irrelevant! *** \n" if self.hidden
    return @tests, @found
  end
  
  private
  
  def perform_test(options)
    should = options[:should]
    actual = options[:actual]
    pass = should == actual
    type = options[:type]
    msg = options[:msg]
    @tests[self.id][:tests] << {
      :type => type,
      :msg => msg,
      :should => should,
      :actual => actual
    } if pass == false
    @found = true if pass == false
  end

end
