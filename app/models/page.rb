class Page < ActiveRecord::Base
  has_and_belongs_to_many :partials
  
  scope :active, where(:active => true, :hidden => false)
  scope :existing, where('hidden=false or hidden is NULL')
end
