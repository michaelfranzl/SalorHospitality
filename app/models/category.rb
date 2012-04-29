# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class Category < ActiveRecord::Base
  belongs_to :tax
  belongs_to :vendor_printer
  has_and_belongs_to_many :options
  has_many :articles
  validates_presence_of :name
  validates_presence_of :tax_id
  acts_as_list

  scope :existing, where(:hidden => false).order('position ASC')
end
