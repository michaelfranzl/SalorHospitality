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
    respond_to do |wants|
      wants.html do
      redirect_to '/' and return unless @current_user.role.permissions.include? "view_all_settlements"
      @from, @to = assign_from_to(params)
      @from = @from ? @from.beginning_of_day : 1.week.ago.beginning_of_day
      @to = @to ? @to.end_of_day : DateTime.now
      @settlements = Settlement.where("created_at >= ? AND created_at <= ?", @from, @to)
      @settlements_sum = @settlements.sum :sum
      #@report = Settlement.report(@settlements) if @settlements.any? # This is deprecated in favor of the JS time range report
      @taxes = @current_vendor.taxes.existing
      @cost_centers = @current_vendor.cost_centers.existing.active
      @selected_cost_center = @current_vendor.cost_centers.find_by_id(params[:cost_center_id]) if params[:cost_center_id] and !params[:cost_center_id].empty?
      end

      wants.json do
        from = Time.parse(params[:day]).beginning_of_day
        to = Time.parse(params[:day]).end_of_day
        settlement_ids = @current_vendor.settlements.where(:created_at => from..to).collect { |s| s.id }
        items = Item.select("items.refund_sum as r, items.category_id as y,items.taxes as t").where(:created_at => from...to, :settlement_id => settlement_ids)
        render :json => items
      end
    end
  end

  def open
    redirect_to '/' and return unless @current_user.role.permissions.include?("finish_own_settlement") or @current_user.role.permissions.include?("finish_all_settlements")
    @users = @current_vendor.users.existing.active
  end

  # ajax
  def create
    render :nothing => true and return unless @current_user.role.permissions.include?("finish_own_settlement") or @current_user.role.permissions.include?("finish_all_settlements")
    @settlement = Settlement.create params[:settlement]
    @settlement.calculate_totals
    @settlement.vendor = @current_vendor
    @settlement.company = @current_company
    @settlement.save
  end

  # ajax
  def update
    render :nothing => true and return unless @current_user.role.permissions.include?("finish_own_settlement") or @current_user.role.permissions.include?("finish_all_settlements")
    @settlement = @current_vendor.settlements.find_by_id params[:id]
    render :nothing => true and return unless @settlement
    @settlement.update_attributes params[:settlement]
    @settlement.finish
    @settlement.print if @current_company.mode == 'local'
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
