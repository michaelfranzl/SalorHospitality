# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Page < ActiveRecord::Base
  include ImageMethods
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :customer
  has_and_belongs_to_many :partials
  has_many :images, :as => :imageable

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank
end
