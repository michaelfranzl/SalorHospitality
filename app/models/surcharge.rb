class Surcharge < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :season
  belongs_to :guest_type
  has_and_belongs_to_many :booking_items
end
