# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
  validate :sku_unique_in_existing, :if => :sku_is_not_weird

  validates_each :prefix, :postfix do |record, attr_name, value|
    if attr_name == :prefix
      record.errors.add(attr_name, I18n.t('activerecord.errors.messages.empty')) if record.not_hidden? and value.empty? and record.postfix.empty?
    else
      record.errors.add(attr_name, I18n.t('activerecord.errors.messages.empty')) if record.not_hidden? and value.empty? and record.prefix.empty?
    end
  end
  
  after_commit :set_article_name
  
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
      error = self.article.vendor.quantities.existing.where(:sku => self.sku).count > 0
    else
      error = self.vendor.quantities.existing.where("sku = '#{self.sku}' AND NOT id = #{ self.id }").count > 0
    end
    if error == true
      errors.add(:sku, I18n.t("activerecord.errors.messages.sku_already_taken"))
      return
    end
  end

  # so that a deleted dynamic nested quantity in articles#new don't add validation errors
  def not_hidden?
    not hidden
  end

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.'))
  end
  
  def set_article_name
    write_attribute(:article_name, self.article.name)
  end
  
  def full_name
    "#{ self.prefix } #{ self.article.name } #{ self.postfix }"
  end
end
