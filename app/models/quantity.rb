# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Quantity < ActiveRecord::Base
  include Scope
  belongs_to :company
  belongs_to :vendor
  belongs_to :article
  has_many :items
  has_many :partials

  validates_presence_of :prefix, :if => :not_hidden?
  validates_presence_of :price, :if => :not_hidden?
  validates_numericality_of :price, :if => :not_hidden?

  # so that a deleted dynamic nested quantity in articles#new don't add validation errors
  def not_hidden?
    not hidden
  end

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.'))
  end
end
