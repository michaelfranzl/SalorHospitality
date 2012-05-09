# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class SettlementsController < ApplicationController

  def index
    @from, @to = assign_from_to(params)
    @from = @from ? @from.beginning_of_day : 1.week.ago.beginning_of_day
    @to = @to ? @to.end_of_day : DateTime.now
    @settlements = @current_vendor.settlements.find(:all, :conditions => { :created_at => @from..@to}).reverse
    @report = Settlement.report(@settlements)
    @taxes = @current_vendor.taxes.existing
    @cost_centers = @current_vendor.cost_centers.existing.active
    @selected_cost_center = @current_vendor.cost_centers.find_by_id(params[:cost_center_id]) if params[:cost_center_id] and !params[:cost_center_id].empty?
  end

  def open
    @users = @current_vendor.users.existing.active
  end

  # ajax
  def create
    @settlement = Settlement.create params[:settlement]
    @settlement.vendor = @current_vendor
    @settlement.company = @current_company
    @settlement.save
  end

  # ajax
  def update
    @settlement = @current_vendor.settlements.find_by_id params[:id]
    render :nothing => true and return unless @settlement
    @orders = Order.where(:vendor_id => @current_vendor, :settlement_id => nil, :user_id => @settlement.user_id, :finished => true)
#puts 'XXXXXXXXXXXXX'
#puts @orders.inspect
#puts 'XXXXXXXXXXXXX'
    @settlement.update_attributes params[:settlement]
    @orders.update_all(:settlement_id => @settlement.id) if @settlement.finished
    @orders.each do |o|
#puts 'YYYYYYYYYYYYY'
#debugger
      Item.where(:vendor_id => @current_vendor, :order_id => o).update_all(:settlement_id => @settlement.id)
    end
    @settlement.print if local_variant?
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
