class Presentation < ActiveRecord::Base
  has_many :partials
  belongs_to :company
  belongs_to :vendor
  
  scope :active, where(:active => true, :hidden => false)
  scope :existing, where('hidden=false or hidden is NULL')
end
