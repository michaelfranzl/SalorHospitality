# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

class Settlement < ActiveRecord::Base
  belongs_to :user
  has_many :orders

  def revenue=(revenue)
    write_attribute(:revenue, revenue.gsub(',', '.'))
  end

  def initial_cash=(initial_cash)
    write_attribute(:initial_cash, initial_cash.gsub(',', '.'))
  end

end
