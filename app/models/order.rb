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

  after_save :set_customers_up

  validates_presence_of :user_id

  accepts_nested_attributes_for :items, :allow_destroy => true #, :reject_if => proc { |attrs| attrs['count'] == '0' || ( attrs['article_id'] == '' && attrs['quantity_id'] == '') }

  def calculate_sum
    ttl = self.items.collect{ |i| i.full_price }.sum
    return ttl
  end

  def calculate_storno_sum
    ttl = self.items.collect{ |i| i.storno_status == 2 ? - i.full_price : 0 }.sum
    return ttl
  end

  def set_priorities
    self.items.each do |i|
      i.update_attribute :priority, i.category.position
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

  def items_to_json
    a = {}
    position = 0
    self.items.existing.positioned.reverse.each do |i|
      position += 100
      d = "i#{i.id}"
      options = {}
      optioncount = 0
      i.options.each do |opt|
        optioncount += 1
        options.merge! optioncount => { :id => opt.id, :n => opt.name, :p => opt.price }
      end
      if i.quantity_id
        a.merge! d => { :id => i.id, :catid => i.category.id, :quantity_id => i.quantity_id, :d => d, :count => i.count, :sc => i.count, :price => i.price, :o => i.comment, :u => i.usage, :t => options, :i => i.i, :pre => i.quantity.prefix, :post => i.quantity.postfix, :n => i.article.name, :s => position }
      else
        a.merge! d => { :id => i.id, :catid => i.category.id, :article_id => i.article_id, :d => d, :count => i.count, :sc => i.count, :price => i.price, :o => i.comment, :u => i.usage, :t => options, :i => i.i, :pre => '', :post => '', :n => i.article.name, :s => position }
      end
    end
    return a.to_json
  end
end
