# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
