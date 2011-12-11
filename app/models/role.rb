class Role < ActiveRecord::Base
  belongs_to :company
  belongs_to :vendor
  has_many :users

  validates_presence_of :name
  serialize :permissions
end
