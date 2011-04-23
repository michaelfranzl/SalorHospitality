class Company < ActiveRecord::Base
  has_many :users
  serialize :unused_order_numbers
end
