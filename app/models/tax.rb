# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

class Tax < ActiveRecord::Base
  has_many :categories
  has_many :items
  has_many :orders

  validates_presence_of :name, :percent
  validates_numericality_of :percent

  scope :existing, where('hidden=false or hidden is NULL')

  def custom_name
    @custom_name = percent.to_s + '%, ' + name
  end
  
  def percent=(percent)
    write_attribute(:percent, percent.gsub(',', '.'))
  end

end
