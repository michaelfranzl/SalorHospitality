# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

class CostCenter < ActiveRecord::Base
  has_many :orders
  validates_presence_of :name

  scope :existing, where('hidden=false or hidden is NULL')
end
