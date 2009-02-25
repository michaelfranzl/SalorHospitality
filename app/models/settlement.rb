class Settlement < ActiveRecord::Base
  belongs_to :user
  has_many :orders
  validates_presence_of :revenue
  validates_numericality_of :revenue
end
