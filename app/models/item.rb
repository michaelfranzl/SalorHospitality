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
  alias_attribute :u, :usage
  alias_attribute :x, :hidden
  alias_attribute :i, :optionslist

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
    self.item.update_attribute :item_id, nil
    self.hidden = true
    self.hidden_by = by_user_id
    self.item_id = nil
    save
  end

  def split
    parent_order = self.order
    vendor = self.vendor
    logger.info "[Split] Now I am in the function split with the parameters self #{ self.inspect }"
    logger.info "[Split] parent_order = self.order = #{ parent_order.inspect }"
    logger.info "[Split] parent_order.order.nil? is #{ parent_order.order.nil? }"

    split_order = parent_order.order
    logger.info "[Split] this parent_order's split_order is #{ split_order.inspect }."
    if split_order.nil?
      logger.info "[Split] I am going to create a brand new split_order, and make it belong to the parent order"
      split_order = Order.create(parent_order.attributes)
      split_order.nr = vendor.get_unique_order_number
      sisr1 = split_order.save
      logger.info "[Split] the result of saving split_order is #{ sisr1.inspect } and split_order itself is #{ split_order.inspect }."
      raise "Konnte die abgespaltene Bestellung nicht speichern. Oops!" if not sisr1
      parent_order.update_attribute :order, split_order  # make an association between parent and child
      split_order.update_attribute :order, parent_order  # ... and vice versa
    end

    logger.info "[Split] self.item is #{ self.item.inspect }."
    if self.item.nil?
      logger.info "[Split] Because self.item is nil, we're going to create one."
      self.item = Item.create(self.attributes)
      self.item.options = self.options
      self.item.count = 0
      self.item.printed_count = 0
      sisr2 = self.item.save
      logger.info "[Split] The result of saving self.item is #{ sisr2.inspect } and it is #{ self.item.inspect }."
      raise "Konnte das neu erstellte abgespaltene Item nicht speichern. Oops!" if not sisr2
      self.item = self.item # make an association between parent and child
      self.item.item = self # ... and vice versa
    end
    self.item.order = split_order # this is the actual moving to the new order
    if self.count > 0 # proper handling of zero count items
      self.item.count += 1
      self.item.printed_count += 1
    end
    #self.item.max_count = self.max_count if self.item.max_count = 0
logger.info self.inspect
logger.info self.item.inspect if self.item
#debugger
    sisr3 = self.item.save
    logger.info "[Split] The result of saving self.item is #{ sisr3.inspect } and it is #{ self.item.inspect }."
    raise "Konnte das bereits bestehende abgespaltene Item nicht überspeichern. Oops!" if not sisr3
    if self.count > 0 # proper handling of zero count items
      self.count -= 1
      self.printed_count -= 1
    end
    logger.info "[Split] self.count = #{ self.count.inspect }"
    if self.count == 0
      #self.hide(0)
  self.item.update_attribute :item_id, nil
  self.hidden = true
  self.hidden_by = 0
  self.item_id = nil
#debugger
#self.reload
raise "partner item is hidden" if self.item and self.item.hidden
    else
      pisr = self.save
      logger.info "[Split] The result of saving self is #{ pisr.inspect } and it is #{ self.inspect }."
      raise "Konnte das bereits bestehende self nicht überspeichern. Oops!" if not pisr
    end

    logger.info "[Split] parent_order before re-read is #{ parent_order.inspect }."
    parent_order = vendor.orders.find(parent_order.id) # re-read
    logger.info "[Split] parent_order after re-read is #{ parent_order.inspect }."
    raise "Konnte parent_order nicht neu laden. Oops!" if not parent_order
    logger.info "[Split] parent_order has #{ parent_order.items.size } items left."

    self.item.calculate_totals if self.item
    self.calculate_totals
    if parent_order.items.existing.empty?
      parent_order.hide(0)
      parent_order.unlink
      logger.info "[Split] deleted parent_order since there were no items left."
      vendor.unused_order_numbers << parent_order.nr
      vendor.save
    else
      parent_order.calculate_totals
    end
    split_order.calculate_totals
  end

end
