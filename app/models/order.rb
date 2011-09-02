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
  belongs_to :settlement
  belongs_to :table
  belongs_to :user
  belongs_to :cost_center
  belongs_to :tax
  has_many :items, :dependent => :destroy
  has_one :order
  has_and_belongs_to_many :coupons

  validates_presence_of :user_id

  #code inspiration from http://ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes
  #This will prevent children_attributes with all empty values to be ignored
  accepts_nested_attributes_for :items, :allow_destroy => true #, :reject_if => proc { |attrs| attrs['count'] == '0' || ( attrs['article_id'] == '' && attrs['quantity_id'] == '') }
  include Scope
  include Base
  def total_with_coupons_and_discounts(ttl)
    if self.coupons.any? then
      seen = []
      puts "Total before: #{ttl}"
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
    puts "Total after: #{ttl}"
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

end
