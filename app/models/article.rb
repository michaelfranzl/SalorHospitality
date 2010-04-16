class Article < ActiveRecord::Base

  belongs_to :category
  has_many :ingredients
  has_many :quantities

  def price=(price)
    write_attribute(:price, price.gsub(',', '.'))
  end

  validates_presence_of :name, :type, :category_id
  
  validates_each :price do |record, attr_name, value|
    record.errors.add(attr_name, 'muss entweder beim Artikel selbst oder bei der Artikelmenge angegeben werden.') if record.quantities.empty? and !value
    
    if record.quantities.empty?
      raw_value = record.send("#{attr_name}_before_type_cast") || value
      begin
        raw_value = Kernel.Float(raw_value)
      rescue ArgumentError, TypeError
        record.errors.add(attr_name, 'ist keine Zahl', :value => raw_value)
      end
    end
  end
  
  #code inspiration from http://ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes
  #This will prevent children_attributes with all empty values to be ignored
  accepts_nested_attributes_for :ingredients, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  accepts_nested_attributes_for :quantities, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs['name'] == '' && attrs['price'] == '' }

  def name_description
    descr = (description.nil? or description.empty?) ? '' : ("  |  " + description)
    name + descr
  end

end
