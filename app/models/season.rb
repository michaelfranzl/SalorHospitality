class Season < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many :surcharges
  has_many :room_prices

  def current?
    now = Time.now
    return ((self.from.month < now.month or (self.from.month == now.month and self.from.day <= now.day)) and (self.to.month > now.month or (self.to.month == now.month and self.to.day > now.day)))
  end
end
