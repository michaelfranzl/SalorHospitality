class GuestType < ActiveRecord::Base
  attr_accessible :vendor_id, :company_id, :taxes_array, :name
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many :room_prices
  has_many :surcharges
  has_many :booking_items
  has_and_belongs_to_many :taxes
  attr_accessible :taxes_array, :name

  def taxes_array=(taxes_array)
    self.taxes = []
    taxes_array.each do |id|
      self.taxes << Tax.find_by_id(id)
    end
    self.save
  end
end
