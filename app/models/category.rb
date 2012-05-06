# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
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
  has_many :partials
  has_many :images, :as => :imageable
  has_many :items
  validates_presence_of :name
  validates_presence_of :tax_id

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank

  def icon_path
    return self.images.first.thumb if self.icon == 'custom'
    return "category_blank.png" if self.icon.nil?
    "/assets/category_#{self.icon}.png"
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
