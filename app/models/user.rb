class User < ActiveRecord::Base
  has_many :settlements
  validates_presence_of :name, :password, :role
end
