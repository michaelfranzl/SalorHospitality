# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class Article < ActiveRecord::Base
  include ImageMethods
  include Scope
  belongs_to :category
  belongs_to :vendor
  belongs_to :company
  has_many :ingredients
  has_many :quantities
  has_many :existing_quantities, :class_name => Quantity, :conditions => ['hidden = ?', false]
  has_many :items
  has_many :partials
  has_many :images, :as => :imageable

  scope :waiterpad, where(:hidden => false, :waiterpad => true ).order('position ASC')

  def price=(price)
    price =  price.gsub(',', '.') if price.class == String
      write_attribute :price, price
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

  accepts_nested_attributes_for :quantities, :allow_destroy => true, :reject_if => proc { |attrs| (attrs['prefix'] == '' && attrs['postfix'] == '' && attrs['price'] == '') || attrs['hidden'] == 1 }
  
  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank

  def hide
    update_attributes :hidden => true, :active => false
    quantities.update_all :hidden => true, :active => false
  end

  def name_description
    descr = (description.nil? or description.empty?) ? '' : ("  |  " + description)
    name + descr
  end
  
end
