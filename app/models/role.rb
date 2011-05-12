class Role < ActiveRecord::Base
  validates_presence_of :name
  serialize :permissions
  has_many :users
end
