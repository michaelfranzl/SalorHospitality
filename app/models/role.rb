class Role < ActiveRecord::Base
  validates_presence_of :name
  serialize :permissions
  has_many :users
  include Scope
  include Base
  before_create :set_model_owner
end
