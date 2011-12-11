class Role < ActiveRecord::Base
  include Scope
  belongs_to :company
  belongs_to :vendor
  has_many :users

  validates_presence_of :name
  serialize :permissions
end
