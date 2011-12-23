class Presentation < ActiveRecord::Base
  include Scope
  has_many :partials
  belongs_to :company
  belongs_to :vendor
end
