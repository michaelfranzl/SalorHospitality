# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

class Ingredient < ActiveRecord::Base
  belongs_to :article
  belongs_to :stock
  validates_presence_of :amount, :stock_id
  validates_numericality_of :amount
end
