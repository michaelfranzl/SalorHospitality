class Presentation < ActiveRecord::Base
  has_many :partials
  
  scope :active, where(:active => true, :hidden => false)
  scope :existing, where('hidden=false or hidden is NULL')
end
