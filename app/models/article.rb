class Article < ActiveRecord::Base

  belongs_to :category
  has_many :ingredients

  def price=(price)
    write_attribute(:price, price.gsub(',', '.'))
  end

  validates_presence_of :name, :price, :type, :category_id
  validates_numericality_of :price

  #code inspiration from http://ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes
  #This will prevent children_attributes with all empty values to be ignored
  accepts_nested_attributes_for :ingredients, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  def name_description
    descr = (description.nil? or description.empty?) ? '' : ("  |  " + description)
    name + descr
  end

end
