# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class Option < ActiveRecord::Base
  include ImageMethods
  include Scope
  belongs_to :company
  belongs_to :vendor
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :items
  has_many :partials
  has_many :images, :as => :imageable

  validates_presence_of :name

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

end
