class Order < ActiveRecord::Base
  belongs_to :settlement
  belongs_to :table
  has_many :items
end
