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

  validates_presence_of :user_id

  accepts_nested_attributes_for :items, :allow_destroy => true #, :reject_if => proc { |attrs| attrs['count'] == '0' || ( attrs['article_id'] == '' && attrs['quantity_id'] == '') }

  def calculate_totals
    self.sum = items.existing.sum(:sum)
    self.tax_amount = items.existing.sum(:tax_amount)
    save
  end

  def calculate_storno_sum
    ttl = self.items.collect{ |i| i.storno_status == 2 ? - i.full_price : 0 }.sum
    return ttl
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
      target_order.sum = target_order.calculate_sum
      target_order.save
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
    self.tax_amount = items.existing.sum(:tax_amount)
    save
    unlink
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
