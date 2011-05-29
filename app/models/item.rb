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

class Item < ActiveRecord::Base
  belongs_to :order
  belongs_to :article
  belongs_to :quantity
  belongs_to :item
  belongs_to :tax
  belongs_to :storno_item, :class_name => 'Item', :foreign_key => 'storno_item_id'
  has_and_belongs_to_many :options
  has_and_belongs_to_many :printoptions, :class_name => 'Option', :join_table => 'items_printoptions'
  validates_presence_of :count, :article_id

  default_scope :order => 'sort DESC'

  
  def real_price
    if price.nil?
      p = self.quantity ? self.quantity.price : self.article.price
    else
      p = price
    end
    return self.storno_status == 2 ? -p : p
  end

  def optionslist=(optionslist)
    self.options = []
    optionslist.split.each do |o|
      self.options << Option.find(o.to_i)
    end
  end

  def optionslist
    self.options.collect{ |o| "#{ o.id } " }.join
  end

  def printoptionslist=(printoptionslist)
    self.printoptions = []
    printoptionslist.split.each { |o| self.printoptions << Option.find(o.to_i) }
  end

  def printoptionslist
    self.printoptions.collect{ |o| "#{ o.id } " }.join
  end

  def category
    self.article.category
  end

  def real_tax
    i = self.tax
    return i if i
    o = self.order.tax
    return o if o
    c = self.article.category.tax
  end

  def count=(count)
    c = count.to_i
    write_attribute :count, c
    write_attribute(:max_count, c) if c > self.max_count
  end

end
