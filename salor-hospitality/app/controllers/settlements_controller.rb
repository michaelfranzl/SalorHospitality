# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SettlementsController < ApplicationController

  def index
    redirect_to '/' and return unless @current_user.role.permissions.include? "view_settlements_table"
    @from, @to = assign_from_to(params)
    @settlements = @current_vendor.settlements.where(:created_at => @from..@to, :finished => true).existing
    @settlement_ids = @settlements.collect{ |s| s.id }
    @taxes = @current_vendor.taxes.existing
    @payment_methods = @current_vendor.payment_methods.existing.where(:change => false)
    @cost_centers = @current_vendor.cost_centers.existing
    cost_center_ids = @cost_centers.collect{ |cc| cc.id }
    @selected_cost_center = params[:cost_center_id] ? @current_vendor.cost_centers.existing.find_by_id(params[:cost_center_id]) : nil
    @scids = @selected_cost_center ? @selected_cost_center.id : ([cost_center_ids] + [nil]).flatten
    @current_day = @from
  end
  
  def show
    redirect_to settlements_path
  end

  def open
    if permit('finish_all_settlements') or permit('view_all_settlements')
      @users = @current_vendor.users.existing.active
    else
      @users = [@current_user]
    end
  end

  # ajax
  def create
    render :nothing => true and return unless @current_user.role.permissions.include?("finish_own_settlement") or @current_user.role.permissions.include?("finish_all_settlements")
    
    user = @current_vendor.users.existing.find_by_id(params[:settlement][:user_id])
    @settlement = user.settlement_start(@current_vendor, @current_user, params[:settlement][:initial_cash])
  end

  # ajax
  def update
    render :nothing => true and return unless @current_user.role.permissions.include?("finish_own_settlement") or @current_user.role.permissions.include?("finish_all_settlements")
    
    user = @current_vendor.users.existing.find_by_id(params[:settlement][:user_id])
    @settlement = user.settlement_stop(@current_vendor, @current_user, params[:settlement][:revenue])
    @settlement = Settlement.new
    @settlement.user = user
  end
  
  # ajax
  def print
    @settlement = get_model
    @settlement.print
    render :nothing => true
  end

  def detailed_list
    @selected_cost_center = @current_vendor.cost_centers.find_by_id(params[:cost_center_id]) if params[:cost_center_id]
    if params[:settlement_id]
      @settlement = @current_vendor.settlements.find_by_id(params[:settlement_id])
      @orders = @settlement.orders.existing
    elsif params[:user_id]
      @settlement = Settlement.new :user_id => params[:user_id]
      if @selected_cost_center
        @orders = @current_vendor.orders.existing.where(:user_id => params[:user_id], :settlement_id => nil, :finished => true, :cost_center_id => @selected_cost_center).reverse
      else
        @orders = @current_vendor.orders.existing.where(:user_id => params[:user_id], :settlement_id => nil, :finished => true).reverse
      end
    end
    redirect_to 'settlements/open' unless @orders
  end

end
