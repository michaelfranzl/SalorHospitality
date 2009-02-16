class Group < ActiveRecord::Base
  has_many :stocks
  validates_presence_of :name
end
