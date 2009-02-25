class User < ActiveRecord::Base
  has_many :settlements
  has_many :orders
  validates_presence_of :login, :password, :role, :title
end
