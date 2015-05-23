# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Option < ActiveRecord::Base
  include ImageMethods
  include Scope
  belongs_to :company
  belongs_to :vendor
  has_and_belongs_to_many :categories
  has_many :partials
  has_many :images, :as => :imageable
  has_one :option_item

  validates_presence_of :name
  validates_presence_of :categories

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.'))
  end

  def price
    (read_attribute :price) || 0
  end

  def set_categories=(array)
    self.categories = []
    array.each do |c|
      self.categories << Category.find_by_id(c.to_i)
    end
    self.save
  end
  
  def hide(by_user_id)
    self.hidden = true
    self.hidden_by = by_user_id
    self.hidden_at = Time.now
    self.save
  end
end
