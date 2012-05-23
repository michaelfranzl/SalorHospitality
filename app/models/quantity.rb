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
  belongs_to :category
  has_many :items
  has_many :partials

  validates_presence_of :price, :if => :not_hidden?
  validates_numericality_of :price, :if => :not_hidden?

  validates_each :prefix, :postfix do |record, attr_name, value|
    if attr_name == :prefix
      record.errors.add(attr_name, I18n.t('activerecord.errors.messages.empty')) if record.not_hidden? and value.empty? and record.postfix.empty?
    else
      record.errors.add(attr_name, I18n.t('activerecord.errors.messages.empty')) if record.not_hidden? and value.empty? and record.prefix.empty?
    end
  end

  # so that a deleted dynamic nested quantity in articles#new don't add validation errors
  def not_hidden?
    not hidden
  end

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.'))
  end
end
