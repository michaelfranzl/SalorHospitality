class Commodity < ActiveRecord::Base
  has_many :items
  has_many :ingredients

  accepts_nested_attributes_for :ingredients
end
