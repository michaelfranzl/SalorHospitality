# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
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
  has_and_belongs_to_many :options
  has_and_belongs_to_many :customers
  validates_presence_of :count, :article_id

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
    self.price = price
    self.tax_percent = tax.percent
    self.tax_id = self.tax.id if self.tax_id.nil?
    self.category_id = article.category.id
    save
    if self.refunded
      self.tax_sum = 0
      self.sum = 0
    else
      self.tax_sum = full_price * tax.percent / 100
      self.sum = full_price
    end
    save
  end

  def price
    p = read_attribute :price
    if p.nil?
      p = self.article.price if self.article
      p = self.quantity.price if self.quantity
    end
    p
  end

  def tax
    t = Tax.find_by_id (read_attribute :tax_id)
    return t if t
    t = self.order.tax if self.order
    return t if t
    t = self.article.tax if self.article
    return t if t
    return self.article.category.tax if self.article
  end

  def count=(count)
    c = count.to_i
    write_attribute :count, c
    write_attribute(:max_count, c) if c > self.max_count
  end

  def total_price
    self.price * self.count
  end

  def options_price
    self.options.sum(:price)
  end

  def total_options_price
    self.options_price * self.count
  end

  def full_price
    self.total_price + self.total_options_price
  end

  def optionslist
    self.options.collect{ |o| o.id }
  end

  def optionslist=(optionslist)
    optionslist.delete '0'
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
    self.save
  end

  def unlink
    self.item = nil # self.item_id = nil does NOT work.
    self.save
  end

  def split
    parent_order = self.order
    vendor = self.vendor
    split_order = parent_order.order
    if split_order.nil?
      split_order = Order.create(parent_order.attributes)
      split_order.nr = vendor.get_unique_order_number
      #sisr1 = split_order.save
      #raise "Konnte die abgespaltene Bestellung nicht speichern. Oops!" if not sisr1
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
    if self.count > 0
      partner_item.count += 1
      partner_item.printed_count += 1
      self.count -= 1
      self.printed_count -= 1
    end
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

end
