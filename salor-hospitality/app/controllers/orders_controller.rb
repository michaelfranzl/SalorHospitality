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
    @categories = @current_vendor.categories.positioned
    @users = @current_vendor.users.existing.active
    @pages = @current_vendor.pages.existing.active
    @partial_htmls_pages = []
    @pages.each do |p|
      @partial_htmls_pages[p.id] = p.evaluate_partial_htmls
    end
    session[:admin_interface] = false
  end
  
  def last
    nr = params[:nr]
    if nr.blank?
      @orders = @current_vendor.orders.existing.where(:finished => true).order('nr DESC').limit(30)
    else
      order = @current_vendor.orders.existing.find_by_nr(nr)
      if order
        from = order.finished_at
        to = from + 1.day
        @orders = @current_vendor.orders.existing.where(:finished => true, :finished_at => from..to).order('nr ASC')
      else
        @orders = []
      end
    end
  end

  def show
    @order = @current_vendor.orders.existing.where(:finished => true).find_by_id(params[:id])
    if @order.nil?
      flash[:error] = I18n.t('not_found')
      redirect_to last_orders_path
      return
    end
    
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

  def refund
    @order = get_model
  end
  
  def reactivate
    @order = get_model
    table = @order.reactivate(@current_user)
    if table
      redirect_to "/orders?table_id=#{table.id}"
    else
      redirect_to order_path(@order)
      flash[:notice] = I18n.t('orders.show.cannot_reactivate')
    end
  end

  def last_invoices
    @recent_unsettled_orders = @current_vendor.orders.existing.where(:settlement_id => nil, :finished => true, :user_id => @current_user.id).order('finished_at DESC').limit(7)
    if permit('finish_all_settlements') or permit('view_all_settlements')
      @permitted_users = @current_vendor.users.existing.active.where('role_weight > 0')
    else
      @permitted_users = [@current_user]
    end
  end
end
