# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Ingredient < ActiveRecord::Base
  include Scope
  belongs_to :article
  belongs_to :stock
  belongs_to :company
  belongs_to :vendor
  validates_presence_of :amount, :stock_id
  validates_numericality_of :amount
end
