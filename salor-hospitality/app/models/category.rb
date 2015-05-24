# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Category < ActiveRecord::Base
  include ImageMethods
  include Scope
  belongs_to :tax
  belongs_to :vendor_printer
  belongs_to :company
  belongs_to :vendor
  has_and_belongs_to_many :options
  has_many :articles
  has_many :quantities
  has_many :partials
  has_many :images, :as => :imageable
  has_many :items
  validates_presence_of :name

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank

  def icon_path
    return self.images.first.thumb if self.icon == 'custom' and self.images.first
    return "/assets/category_blank.png" if self.icon.nil?
    "/assets/category_#{self.icon}.png"
  end
  
  def self.sort(categories,type)
    type.map! {|t| t.to_i}
    categories.each do |cat|
      cat.position ||= 0
      cat.update_attribute :position,type.index(cat.id) + 1 if type.index(cat.id)
    end
    return categories
  end

end
