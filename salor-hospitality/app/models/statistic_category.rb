class StatisticCategory < ActiveRecord::Base
  include Scope
  include Base
  
  belongs_to :vendor
  belongs_to :company
  has_many :articles
  validates_presence_of :name
end
