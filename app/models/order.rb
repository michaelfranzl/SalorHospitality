# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.
class Order < ActiveRecord::Base
  belongs_to :settlement
  belongs_to :table
  belongs_to :user
  belongs_to :cost_center
  belongs_to :tax
  has_many :items, :dependent => :destroy
  has_one :order

  validates_presence_of :user_id

  #code inspiration from http://ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes
  #This will prevent children_attributes with all empty values to be ignored
  accepts_nested_attributes_for :items, :allow_destroy => true #, :reject_if => proc { |attrs| attrs['count'] == '0' || ( attrs['article_id'] == '' && attrs['quantity_id'] == '') }

  def calculate_sum
    self.items.collect{ |i| i.full_price }.sum
  end

  def calculate_storno_sum
    self.items.collect{ |i| i.storno_status == 2 ? - i.full_price : 0 }.sum
  end

  def set_priorities
    self.items.each do |i|
      i.update_attribute :priority, i.category.position
    end
  end

end
