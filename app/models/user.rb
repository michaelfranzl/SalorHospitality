# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class User < ActiveRecord::Base
  include Scope
  has_many :settlements
  has_many :orders
  has_one :cash_drawer
  belongs_to :role
  belongs_to :company
  has_and_belongs_to_many :vendors
  has_many :histories
  has_many :bookings
  has_and_belongs_to_many :tables
  validates_presence_of :login, :password, :title

  def tables_array=(ids)
    self.tables = []
    ids.each do |id|
      self.tables << Table.find_by_id(id.to_i)
    end
  end
end
