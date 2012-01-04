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
  belongs_to :tax
  belongs_to :vendor_printer
  has_and_belongs_to_many :options
  has_many :articles
  has_many :partials
  has_many :images, :as => :imageable
  validates_presence_of :name
  validates_presence_of :tax_id
  acts_as_list
  include ImageMethods

  scope :existing, where(:hidden => false).order('position ASC')

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

end
