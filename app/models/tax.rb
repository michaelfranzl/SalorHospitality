# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Tax < ActiveRecord::Base
  include Scope
  has_many :categories
  has_many :items
  has_many :orders
  belongs_to :company
  belongs_to :vendor
  has_and_belongs_to_many :guest_types

  validates_presence_of :name, :percent
  validates_numericality_of :percent

  def custom_name
    @custom_name = percent.to_s + '%, ' + name
  end
  
  def percent=(percent)
    percent = percent.gsub(',', '.') if percent.class == String
    write_attribute(:percent, percent)
  end

end
