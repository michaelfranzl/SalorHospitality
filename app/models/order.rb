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
  has_and_belongs_to_many :customers

  after_save :set_customers_up

  validates_presence_of :user_id

  #code inspiration from http://ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes
  #This will prevent children_attributes with all empty values to be ignored
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
    a = []
    self.items.each do |i|
debugger
      a << {:a => i.article_id, :q => i.quantity_id, :c => i.comment, :i => i.count, :s => i.position, :p => i.price, :u => i.usage, :l => i.label, :ol => i.optionslist, :on => i.optionsnames, :id => i.id }
    end
    return a.to_json
  end
end
