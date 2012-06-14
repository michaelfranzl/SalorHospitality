class Season < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many :surcharges
  has_many :surcharge_items
  has_many :room_prices
  has_many :bookings

  validates_uniqueness_of :name
  validates_presence_of :from_date, :to_date, :name

  after_save :calculate_duration

  def self.current(vendor)
    now = Time.now
    current_season = Season.where("(MONTH(from_date)<#{now.month} OR (MONTH(from_date) = #{now.month} AND DAY(from_date) <= #{now.day})) AND (MONTH(to_date) > #{now.month} OR (MONTH(to_date) = #{now.month} AND DAY(to_date) > #{now.day})) AND vendor_id = #{vendor.id}").order('duration ASC').first
  end

  def from_date=(from)
    write_attribute :from_date, Time.parse("2012-" + from.strftime("%m-%d"))
  end

  def to_date=(to)
    write_attribute :to_date, Time.parse("2012-" + to.strftime("%m-%d"))
  end

  def calculate_duration
    if (self.from_date.month > self.to_date.month) or (self.from_date.month == self.to_date.month and self.from_date.day > self.to_date.day)
      duration = - (self.to_date - self.from_date)
    else
      duration = self.to_date - self.from_date
    end
    write_attribute :duration, duration
  end
end
