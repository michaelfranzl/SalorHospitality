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
  #belongs_to :storno_item, :class_name => 'Item', :foreign_key => 'storno_item_id'
  belongs_to :vendor
  belongs_to :company
  belongs_to :category
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
  alias_attribute :u, :usage
  alias_attribute :x, :hidden
  alias_attribute :i, :optionslist

  def hide(by)
    self.unlink
    self.hidden = true
    self.hidden_by = by
    save
  end

  def unlink
    self.item.update_attribute :item_id, nil
    write_attribute :item_id, nil
  end

  def split
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

    if separated_item.storno_status != 0
      stornoitem = separated_item.storno_item
      stornoitem.count = separated_item.count 
      stornoitem.save
    end
    separated_item.calculate_totals
    self.calculate_totals
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
    self.category_id = article.category.id
    if self.refunded
      self.tax_sum = 0
      self.sum = 0
    else
      self.tax_sum = full_price / tax.percent
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
    #return self.storno_status == 2 ? -p : p
  end

  def options_price
    self.options.sum(:price)
    #return self.storno_status == 2 ? -p : p
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
end
