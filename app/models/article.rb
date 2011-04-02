class Article < ActiveRecord::Base

  belongs_to :category
  has_many :ingredients
  has_many :quantities
  has_many :items

  default_scope where(:hidden => false)

  def price=(price)
    write_attribute(:price, price.gsub(',', '.'))
  end

  def self.find_in_menucard
    find(:all, :conditions => 'menucard = 1 AND hidden = false', :order => 'sort DESC')
  end

  def self.find_in_blackboard
    find(:all, :conditions => 'blackboard = 1 AND hidden = false', :order => 'price')
  end

  def self.find_in_waiterpad
    find(:all, :conditions => 'waiterpad = 1 AND hidden = false', :order => 'price')
  end
  
  validates_presence_of :name, :category_id
  
  validates_each :price do |record, attr_name, value|
    record.errors.add(attr_name, I18n.t(:must_be_entered_either_for_article_or_for_quantity)) if record.quantities.empty? and !value
    
    if record.quantities.empty?
      raw_value = record.send("#{attr_name}_before_type_cast") || value
      begin
        raw_value = Kernel.Float(raw_value)
      rescue ArgumentError, TypeError
        record.errors.add(attr_name, I18n.t(:is_no_number), :value => raw_value)
      end
    end
  end
  
  #code inspiration from http://ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes
  #This will prevent children_attributes with all empty values to be ignored
  accepts_nested_attributes_for :ingredients, :allow_destroy => true, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  accepts_nested_attributes_for :quantities, :allow_destroy => true, :reject_if => proc { |attrs| attrs['prefix'] == '' && attrs['postfix'] == '' && attrs['price'] == '' }

  def name_description
    descr = (description.nil? or description.empty?) ? '' : ("  |  " + description)
    name + descr
  end
  
end
