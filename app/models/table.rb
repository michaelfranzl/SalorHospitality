# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Table < ActiveRecord::Base
  include Scope
  has_many :orders
  belongs_to :user
  belongs_to :company
  belongs_to :vendor
  validates_presence_of :name
  has_and_belongs_to_many :users
  belongs_to :user, :class_name => 'User', :foreign_key => 'active_user_id'
  validates_presence_of :name
end
