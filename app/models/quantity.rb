# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Quantity < ActiveRecord::Base

  belongs_to :article
  has_many :items

  scope :existing, where(:hidden => false).order('position ASC')
  scope :active_and_sorted, where(:hidden => false, :active => true).order('position ASC')

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.'))
  end

  validates_presence_of :prefix
  validates_presence_of :price
  validates_numericality_of :price

end
