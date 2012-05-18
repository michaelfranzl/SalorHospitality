class Customer < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  has_and_belongs_to_many :orders
  has_and_belongs_to_many :items
end
