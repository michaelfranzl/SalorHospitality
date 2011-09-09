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

class Quantity < ActiveRecord::Base

  belongs_to :article
  has_many :items
  include Scope
  include Base
  before_create :set_model_owner
  scope :existing, where(:hidden => false).order('position ASC')
  scope :active_and_sorted, where(:hidden => false, :active => true).order('position ASC')

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.'))
  end

  validates_presence_of :prefix
  validates_presence_of :price
  validates_numericality_of :price

end
