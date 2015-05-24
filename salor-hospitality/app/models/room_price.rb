# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class RoomPrice < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many   :rooms
  belongs_to :room_type
  belongs_to :guest_type
  belongs_to :season

  def self.generate(vendor)
    seasons = vendor.seasons.existing
    room_types = vendor.room_types.existing
    guest_types = vendor.guest_types.existing
    seasons.each do |s|
      room_types.each do |rt|
        guest_types.each do |gt|
          unless vendor.room_prices.existing.where(:season_id => s.id, :room_type_id => rt.id, :guest_type_id => gt.id).any?
            RoomPrice.create :vendor_id => vendor.id, :company_id => vendor.company.id, :season_id => s.id, :room_type_id => rt.id, :guest_type_id => gt.id, :base_price => rand(50) + 50
          end
        end
      end
    end
  end
  
  def base_price=(base_price)
    write_attribute :base_price, base_price.to_s.gsub(',','.')
  end
end
