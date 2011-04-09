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

module SettlementsHelper

  def initialize_total_variables
    total_net = Array.new(@taxes.size + 1) { 0 }
    total_gro = Array.new(@taxes.size + 1) { 0 }
    return total_net, total_gro
  end
  
  def initialize_settlement_variables
    s_net = Array.new(@taxes.size + 1) { 0 }
    s_gro = Array.new(@taxes.size + 1) { 0 }
    return s_net, s_gro
  end
  
  def calculate_sums(s, s_net, s_gro, total_net, total_gro)
    s.orders.each do |o|
      next if @selected_cost_center and o.cost_center != @selected_cost_center
      o.items.each do |i|
        price = i.real_price
        price = -price if i.storno_status == 2
        s_gro[i.article.category.tax.id] += i.count * price
      end
    end
    
    @taxes.each do |tax|
      s_net[tax.id] = s_gro[tax.id] / (1 + tax.percent/100.0)
      total_net[tax.id] += s_net[tax.id].round(2)
      total_gro[tax.id] += s_gro[tax.id] #.round(2) not neccessary
    end
    return s_gro, total_net, total_gro
  end
  
  
end
