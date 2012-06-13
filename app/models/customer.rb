class Customer < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many :orders
  has_many :bookings

  def to_hash
    {:id => self.id, :name => self.full_name(true)}
  end

  def full_name(simple = false)
    if simple then
      return "#{ self.last_name }, #{ self.first_name }"
    else
      return "#{ self.first_name } #{ self.last_name } #{ self.company_name }"
    end
  end
end
