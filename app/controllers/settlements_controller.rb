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
    @settlements = Settlement.find(:all, :conditions => { :created_at => (@from)..@to })
    @taxes = Tax.all
    @cost_centers = CostCenter.all
    @selected_cost_center = CostCenter.find(params[:cost_center_id]) if params[:cost_center_id] and !params[:cost_center_id].empty?
  end

  def show
    @settlement = Settlement.find params[:id]
    params[:cost_center_id] ||= CostCenter.first.id if CostCenter.first
    @selected_cost_center = CostCenter.find(params[:cost_center_id]) if CostCenter.first
    @orders = Order.find(:all, :conditions => { :settlement_id => @settlement.id }, :order => 'created_at DESC')
  end

  def new
    @settlement = Settlement.new
    @settlement.user_id = params[:user_id]
    @orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true }, :order => 'created_at DESC')
  end

  def edit
    @settlement = Settlement.find params[:id]
    @orders = Order.find_all_by_settlement_id @settlement.id
  end

  def update
    @settlement = Settlement.find(params[:id])
    @settlement.update_attributes(params[:settlement])
    redirect_to settlements_path
  end

  def create
    @settlement = Settlement.new(params[:settlement])
    
    @settlement.user_id = params[:user_id]
    @orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true })
    if @settlement.save
      @orders.each do |so|
        so.settlement_id = @settlement.id
        so.save
      end
      redirect_to '/orders/unsettled'
    else
      render :new
    end
  end

  def open
    @users = @current_company.users.active
    if @current_user.role.permissions.include? 'finish_all_settlements'
      @unsettled_orders = Order.find(:all, :conditions => { :settlement_id => nil, :finished => true })
    else
      @unsettled_orders = Order.find(:all, :conditions => { :settlement_id => nil, :finished => true, :user_id => @current_user.id })
    end
    unsettled_userIDs = @unsettled_orders.collect { |uo| uo.user_id }
    unsettled_userIDs.uniq!
    @unsettled_users = User.find(:all, :conditions => { :id => unsettled_userIDs })
    flash[:notice] = t(:there_are_no_open_settlements) if @unsettled_users.empty?
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

end
