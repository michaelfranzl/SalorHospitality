# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

class Article < ActiveRecord::Base

  belongs_to :category
  has_many :ingredients
  has_many :quantities
  has_many :existing_quantities, :class_name => Quantity, :conditions => ['hidden = ?', false]
  has_many :items

  scope :existing, where(:hidden => false).order('position ASC')
  scope :menucard, where(:hidden => false, :menucard => true ).order('position ASC')
  scope :waiterpad, where(:hidden => false, :waiterpad => true ).order('position ASC')

  def price=(price)
    write_attribute :price, price.gsub(',', '.')
  end
  
  validates_presence_of :name, :category_id
  
  validates_each :price do |record, attr_name, value|
    #since some records are not saved yet, check manually if one of the quantities is hidden
    existing_quantities = false
    record.quantities.each { |qu| existing_quantities = true and break if not qu.hidden }

    record.errors.add(attr_name, I18n.t(:must_be_entered_either_for_article_or_for_quantity)) if not existing_quantities and !value
    
    if not existing_quantities
      raw_value = record.send("#{attr_name}_before_type_cast") || value
      begin
        raw_value = Kernel.Float(raw_value)
      rescue ArgumentError, TypeError
        record.errors.add(attr_name, I18n.t(:is_no_number), :value => raw_value)
      end
    end
  end
  
  accepts_nested_attributes_for :ingredients, :allow_destroy => true, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  accepts_nested_attributes_for :quantities, :allow_destroy => true, :reject_if => proc { |attrs| attrs['prefix'] == '' && attrs['postfix'] == '' && attrs['price'] == '' }

  def name_description
    descr = (description.nil? or description.empty?) ? '' : ("  |  " + description)
    name + descr
  end
  
end
