# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Option < ActiveRecord::Base
  belongs_to :category
  has_and_belongs_to_many :items
  validates_presence_of :name, :category_id
  scope :existing, where(:hidden => false).order('position ASC')


  def price=(price)
    write_attribute(:price, price.gsub(',', '.'))
  end

  def price
    (read_attribute :price) || 0
  end
end
