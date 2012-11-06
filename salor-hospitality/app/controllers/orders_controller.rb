# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class OrdersController < ApplicationController

  def index
    @tables = @current_user.tables.where(:vendor_id => @current_vendor).existing
    @categories = @current_vendor.categories.positioned
    @users = @current_vendor.users.existing.active
    session[:admin_interface] = false
  end

  def show
    if params[:id] != 'last'
      @order = @current_vendor.orders.existing.find(params[:id])
    else
      @order = @current_vendor.orders.existing.find_all_by_paid(true).last
    end
    redirect_to '/' and return if not @order
    
    @previous_order, @next_order = neighbour_models('orders',@order)
    
    respond_to do |wants|
      wants.html
      wants.bill { render :text => generate_escpos_invoice(@order) }
    end
  end

  def by_nr
    @order = @current_vendor.orders.existing.find_by_nr(params[:nr])
    if @order
      redirect_to order_path(@order)
    else
      redirect_to order_path(@current_vendor.orders.existing.last)
    end
  end

  def toggle_admin_interface
    if session[:admin_interface]
      session[:admin_interface] = !session[:admin_interface]
    else
      session[:admin_interface] = true
    end
    render :json => session[:admin_interface]
  end

  def refund
    @order = get_model
  end

  def last_invoices
    @recent_unsettled_orders = @current_vendor.orders.existing.where(:settlement_id => nil, :finished => true, :user_id => @current_user.id).limit(5)
    if @current_user.role.permissions.include? 'finish_all_settlements'
      @permitted_users = @current_vendor.users.existing.active
    elsif @current_user.role.permissions.include? 'finish_own_settlement'
      @permitted_users = [@current_user]
    else
      @permitted_users = []
    end
  end
end
