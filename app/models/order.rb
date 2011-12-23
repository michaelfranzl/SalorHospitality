# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
  has_and_belongs_to_many :coupons
  has_and_belongs_to_many :discounts
  has_and_belongs_to_many :customers

  after_create :add_needed_discounts
  after_save :set_customers_up

  validates_presence_of :user_id

  #code inspiration from http://ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes
  #This will prevent children_attributes with all empty values to be ignored
  accepts_nested_attributes_for :items, :allow_destroy => true #, :reject_if => proc { |attrs| attrs['count'] == '0' || ( attrs['article_id'] == '' && attrs['quantity_id'] == '') }

  def add_needed_discounts
    n = Time.now.strftime("%H%I").to_i
    $DISCOUNTS.each do |d|
      if d.time_based and d.start_time <= n and d.end_time >= n then
        if not self.discount_ids.include? d.id then
          self.discounts << d
          save
        end
      end
    end #$DISCOUNTS.each
  end
  def add_discount(d)
    d = Discount.scopied.find_by_id(d) if d.class == Fixnum or d.class == String
    return if not d.class == Discount
    if not self.discount_ids.include? d.id then
      self.discounts << d
    end
  end
  def total_with_coupons_and_discounts(ttl)
    if self.coupons.any? then
      seen = []
      puts "Total before Coupons: #{ttl}"
      self.coupons.each do |coupon|
        if seen.include? coupon.id and not coupon.more_than_1_allowed then
          next
        end
        if coupon.ctype == 0 then
          ttl -= coupon.amount
        elsif coupon.ctype == 1 then
          ttl -= ttl * (coupon.amount / 100)
        elsif coupont.type == 2 then
          # this is a b1g1, need to loop over the items.
          self.items.each do |item|
            if item.article.id == coupon.article_id and item.count > 1 then
              ttl -= item.price
            end
          end #self.items.each
        end #if coupon.ctype
        seen << coupon.id
      end #self.coupons.each
    end #if self.coupons.any
    puts "Total after coupons: #{ttl}"
    if self.discounts.any? then
      self.discounts.each do |d|
        if d.dtype == 0 then
          puts "Applying discount #{d.name} with amount #{d.amount} which is fixed"
          ttl -= d.amount #doesn't matter, as it's a fixed amount...
        elsif d.dtype == 1 then
          if d.article_id or d.category_id then
            self.items.each do |i|
              if i.article.id == d.article_id or i.article.category_id == d.category_id then
                amnt = i.price * (d.amount / 100)
                puts "Applying discount #{d.name} with amount #{amnt} against an item"
                ttl -= amnt
              end
            end # self.items.each
          else
            puts "Applying discount #{d.name} with amount #{amnt} to order"
            amnt = ttl * (d.amount / 100)
            ttl -= amnt
          end # if article_id or category_id
        end
      end
    end # self.discounts.any?
    puts "Total after discount: #{ttl}"
    return ttl
  end
  def calculate_sum
    ttl = self.items.collect{ |i| i.full_price }.sum
    ttl = total_with_coupons_and_discounts(ttl)
    return ttl
  end

  def calculate_storno_sum
    ttl = self.items.collect{ |i| i.storno_status == 2 ? - i.full_price : 0 }.sum
    ttl = total_with_coupons_and_discounts(ttl)
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
end
