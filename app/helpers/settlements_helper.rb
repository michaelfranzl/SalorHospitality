module SettlementsHelper

  def initialize_total_varaibles
    total_net = Array.new(@taxes.size + 1) { 0 }
    total_gro = Array.new(@taxes.size + 1) { 0 }
    return total_net, total_gro
  end
  
  def initialize_settlement_varaibles
    s_net = Array.new(@taxes.size + 1) { 0 }
    s_gro = Array.new(@taxes.size + 1) { 0 }
    return s_net, s_gro
  end
  
  def calculate_sums(s, s_net, s_gro, total_net, total_gro)
    s.orders.each do |o|
      o.items.each do |i|
        next if @selected_cost_center and i.cost_center != @selected_cost_center
        #price = @current_user.role == 2 ? i.article.price : 0
        price = i.article.price
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
