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

class Category < ActiveRecord::Base
  include ImageMethods
  include Scope
  acts_as_list
  belongs_to :tax
  belongs_to :vendor_printer
  belongs_to :company
  belongs_to :vendor
  has_and_belongs_to_many :options
  has_many :articles
  has_many :discounts
  has_many :partials
  has_many :images, :as => :imageable
  validates_presence_of :name
  validates_presence_of :tax_id

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank

  def icon_path
    return self.images.first.thumb if self.icon == 'custom'
    return "/images/category_blank.png" if self.icon.nil?
    "/images/category_#{self.icon}.png"
  end

  def self.process_custom_icon(params)
    params[:icon] = 'custom' if (params[:images_attributes] and params[:images_attributes]['0'][:file_data])
    params
  end
  
  def self.sort(categories,type)
    type.map! {|t| t.to_i}
    categories.each do |cat|
      cat.position ||= 0
      cat.update_attribute :position,type.index(cat.id) + 1 if type.index(cat.id)
    end
    return categories
  end

end
