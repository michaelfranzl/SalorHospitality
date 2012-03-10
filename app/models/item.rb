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
  include Scope
  belongs_to :order
  belongs_to :article
  belongs_to :quantity
  belongs_to :item
  belongs_to :tax
  belongs_to :storno_item, :class_name => 'Item', :foreign_key => 'storno_item_id'
  belongs_to :vendor
  belongs_to :company
  has_and_belongs_to_many :options
  has_and_belongs_to_many :customers
  validates_presence_of :count, :article_id

  scope :prioritized, order('priority ASC')

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
    return self.article.category.tax if self.article
  end

  def count=(count)
    c = count.to_i
    write_attribute :count, c
    write_attribute(:max_count, c) if c > self.max_count
  end

  def total_price
    p = self.price * self.count
    return self.storno_status == 2 ? -p : p
  end

  def options_price
    p = self.options.collect{ |o| o.price }.sum
    return self.storno_status == 2 ? -p : p
  end

  def total_options_price
    self.options_price * self.count
  end

  def full_price
    self.total_price + self.total_options_price
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

  def category
    self.article.category
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
  
end
