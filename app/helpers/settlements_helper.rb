# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
module SettlementsHelper
  
  def calculate_sums(s, s_net, s_gro, total_net, total_gro)
    s_gro = s.orders.existing.where(:cost_center => @selected_cost_center).sum(:sum)
    s_net = s_gro - s.orders.existing.where(:cost_center => @selected_cost_center).sum(:tax_sum)
    
    @taxes.each do |tax|
      s_net[tax.id] = s_gro[tax.id] / (1 + tax.percent/100.0)
      total_net[tax.id] += s_net[tax.id].round(2)
      total_gro[tax.id] += s_gro[tax.id]
    end
    return s_gro, total_net, total_gro
  end

end
