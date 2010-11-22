class Table < ActiveRecord::Base
  has_many :orders
  belongs_to :user
  validates_presence_of :name
end
