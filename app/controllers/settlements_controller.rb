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

class SettlementsController < ApplicationController
  def index
    @from, @to = assign_from_to(params)
    @settlements = Settlement.find(:all, :conditions => { :created_at => @from..@to })
    @taxes = Tax.all
    @cost_centers = CostCenter.all
    @selected_cost_center = CostCenter.find(params[:cost_center_id]) if params[:cost_center_id] and !params[:cost_center_id].empty?
  end

  def new
    @settlement = Settlement.new
    @settlement.user_id = params[:user_id]
    @orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true }, :order => 'created_at DESC')
  end

  def detailed_list
    @selected_cost_center = CostCenter.find(params[:cost_center_id]) if params[:cost_center_id]
    if params[:settlement_id]
      @settlement = Settlement.find_by_id params[:settlement_id]
      @orders = @settlement.orders
    elsif params[:user_id]
      @settlement = Settlement.new :user_id => params[:user_id]
      @orders = Order.find_all_by_user_id(params[:user_id], :conditions => { :settlement_id => nil, :finished => true }, :order => 'id DESC' )
    end
    redirect_to 'settlements/open' unless @orders
  end

  def print
    @settlement = Settlement.find_by_id params[:id]
    render :nothing => true and return if not @settlement
    @orders = @settlement.orders
    printers = initialize_printers
    text = generate_escpos_settlement(@settlement, @orders)
    do_print printers, @current_company.vendor_printers.first.id, text
    close_printers printers
    redirect_to settlements_path
  end

  def update
    @settlement = Settlement.find params[:id]
    @settlement.update_attributes params[:settlement]
    @orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true })
    if @settlement.finished
      @orders.each { |o| o.update_attribute :settlement_id, @settlement.id }
      @settlement = Settlement.new :user_id => @settlement.user_id
    end
    if params[:print] != '' and not saas?
      printers = initialize_printers
      text = generate_escpos_settlement(@settlement, @orders)
      do_print printers, params[:port].to_i, text
      close_printers printers
    end
    respond_to do |wants|
      wants.js
    end
  end

  def create
    @settlement = Settlement.create params[:settlement]
    respond_to do |wants|
      wants.js
    end
  end

  def open
    @users = @current_company.users.active
  end

  
  private

    def assign_from_to(p)
      f = Date.civil( p[:from][:year ].to_i,
                      p[:from][:month].to_i,
                      p[:from][:day  ].to_i) if p[:from]
      t = Date.civil( p[:to  ][:year ].to_i,
                      p[:to  ][:month].to_i,
                      p[:to  ][:day  ].to_i) if p[:to]

      f ||= 1.week.ago
      t ||= 0.week.ago

      return f, t
    end

    def generate_escpos_settlement(settlement, orders)
      string =
      "\e@"     +  # Initialize Printer
      "\e!\x38"    # doube tall, double wide, bold

      if settlement.id
        title = "#{ t('activerecord.models.settlement.one') } ##{ settlement.id }\n#{ settlement.user.login }\n\n"
      else
        title = "#{ t('activerecord.models.settlement.one') }\n#{ settlement.user.login }\n\n"
      end

      string += title +
      "\ea\x00" +  # align left
      "\e!\x00"    # Font A

      string += "Gestartet:     #{ l(settlement.created_at, :format => :datetime_iso) }\n"
      string += "Abgeschlossen: #{ l(settlement.updated_at, :format => :datetime_iso) }\n" if settlement.finished?

      string += "\nNr.    Tisch   Zeit  Kostenstelle    Summe\n"

      total_costcenter = Hash.new
      CostCenter.all.each { |cc| total_costcenter[cc.id] = 0 }

      list_of_orders = ''
      orders.each do |o|
        cc = o.cost_center.name
        t = l(o.created_at, :format => :time_short)
        list_of_orders += "#%6u %4s %7s %12.12s %8.2f\n" % [o.nr, o.table.abbreviation, t, cc, o.sum]
        total_costcenter[o.cost_center.id] += o.sum
      end

      string += list_of_orders +
      "                               -----------\n" +
      "\e!\x18" +  # double tall, bold
      "\ea\x02"    # align right

      list_of_costcenters = ''
      CostCenter.all.each do |cc|
        list_of_costcenters += "%s:  EUR %9.2f\n" % [cc.name, total_costcenter[cc.id]]
      end

      string += list_of_costcenters
      initial_cash = settlement.initial_cash ? "\nStartbetrag:  EUR %9.2f\n" % [settlement.initial_cash] : ''
      revenue = settlement.revenue ? "Endbetrag:  EUR %9.2f\n" % [settlement.revenue] : ''

      string += initial_cash + revenue +

      "\e!\x01" + # Font A
      "\n\n\n\n\n" +
      "\x1DV\x00" # paper cut

      sanitize_character_encoding(string)
    end

end
