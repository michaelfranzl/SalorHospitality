# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Article < ActiveRecord::Base
  include ImageMethods
  include Scope
  belongs_to :category
  belongs_to :statistic_category
  belongs_to :vendor
  belongs_to :company
  has_many :ingredients
  has_many :quantities
  has_many :existing_quantities, -> { where processed: false }, :class_name => Quantity
  has_many :items
  has_many :partials
  has_many :images, :as => :imageable
  has_and_belongs_to_many :taxes

  # scope :waiterpad, -> where(:hidden => false, :waiterpad => true ).order('position ASC')

  # Validations 
  validates_presence_of :name, :category_id, :taxes
  validate :sku_unique_in_existing, :if => :sku_is_not_weird
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
 
  # Nested attributes
  accepts_nested_attributes_for :ingredients, :allow_destroy => true, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  accepts_nested_attributes_for :quantities, :allow_destroy => true, :reject_if => proc { |attrs| (attrs['prefix'].blank? && attrs['postfix'].blank? && attrs['price'].blank?) || attrs['hidden'] == 1 }
  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank


  # Methods
  
  def sku_is_not_weird
    if sku and not self.sku == self.sku.gsub(/[^0-9a-zA-Z]/, "") then
      errors.add(:sku, I18n.t("activerecord.errors.messages.dont_use_weird_skus"))
      return false
    end
    return true
  end
  
  def sku_unique_in_existing
    return if self.sku.blank?
    if self.new_record?
      error = self.vendor.articles.existing.where(:sku => self.sku).count > 0
    else
      error = self.vendor.articles.existing.where("sku = '#{self.sku}' AND NOT id = #{ self.id }").count > 0
    end
    if error == true
      errors.add(:sku, I18n.t("activerecord.errors.messages.sku_already_taken"))
      return
    end
  end

  def price=(price)
    price = price.gsub(',', '.') if price.class == String
    write_attribute :price, price
  end
  
  def inactive=(val)
    self.active = !val
    self.save!
  end
  
  def inactive
    return self.active != true
  end

  def hide(user_id)
    self.hidden = true
    self.active = false
    self.hidden_by = user_id
    self.hidden_at = Time.now
    self.save
    self.quantities.update_all(:hidden => true, :active => false, :hidden_by => user_id, :hidden_at => Time.now)
  end

  def name_description
    descr = (description.nil? or description.empty?) ? '' : ("  |  " + description)
    name + descr
  end

  def taxes_array=(taxes_array)
    self.taxes = []
    taxes_array.each do |id|
      self.taxes << Tax.find_by_id(id)
    end
    self.save
  end
  
end
