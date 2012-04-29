# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
module SettlementsHelper
  
  def calculate_sums(s, s_net, s_gro, total_net, total_gro)
    s.orders.each do |o|
      next if @selected_cost_center and o.cost_center != @selected_cost_center
      o.items.each do |i|
        s_gro[i.tax.id] += i.total_price
        i.options.each do |opt|
          s_gro[i.tax.id] += (i.storno_status == 2 ? -(i.count * opt.price) : (i.count * opt.price))
        end
      end
    end
    
    @taxes.each do |tax|
      s_net[tax.id] = s_gro[tax.id] / (1 + tax.percent/100.0)
      total_net[tax.id] += s_net[tax.id].round(2)
      total_gro[tax.id] += s_gro[tax.id]
    end
    return s_gro, total_net, total_gro
  end

end
