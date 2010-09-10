class Order < ActiveRecord::Base
  belongs_to :settlement
  belongs_to :table
  belongs_to :user
  has_many :items
  has_one :order

  validates_presence_of :user_id

  #code inspiration from http://ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes
  #This will prevent children_attributes with all empty values to be ignored
  accepts_nested_attributes_for :items, :allow_destroy => true, :reject_if => proc { |attrs| attrs['count'] == '0' || ( attrs['article_id'] == '' && attrs['quantity_id'] == '') }

end
