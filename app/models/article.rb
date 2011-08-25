# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Article < ActiveRecord::Base

  belongs_to :category
  belongs_to :company
  has_many :ingredients
  has_many :quantities
  has_many :existing_quantities, :class_name => Quantity, :conditions => ['hidden = ?', false]
  has_many :items

  scope :existing, where(:hidden => false).order('position ASC')
  scope :menucard, where(:hidden => false, :menucard => true ).order('position ASC')
  scope :waiterpad, where(:hidden => false, :waiterpad => true ).order('position ASC')
  include Scope
  include Base

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

  accepts_nested_attributes_for :quantities, :allow_destroy => true, :reject_if => proc { |attrs| attrs['prefix'] == '' && attrs['postfix'] == '' && attrs['price'] == '' }

  def name_description
    descr = (description.nil? or description.empty?) ? '' : ("  |  " + description)
    name + descr
  end
  
end
