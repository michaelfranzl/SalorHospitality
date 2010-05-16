class Category < ActiveRecord::Base
  belongs_to :tax
  has_many :articles

  validates_presence_of :name, :tax_id
end
