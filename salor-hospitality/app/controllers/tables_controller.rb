# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class TablesController < ApplicationController

  before_filter :check_permissions, :except => [:index, :show]
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  respond_to :html, :js
  
  def index
    @tables = @current_user.tables.existing.active.where(:vendor_id => @current_vendor).order(:name) unless @current_customer
    @tables ||= []
    respond_with do |wants|
      wants.html
      wants.js {
        tables = {}
        @tables.each do |t|
          tid = t.id
          tables[tid] = {
                         :id => tid,
                         :n => t.name,
                         :l => t.left,
                         :t => t.top,
                         :w => t.width,
                         :h => t.height,
                         :lm => t.left_mobile,
                         :tm => t.top_mobile,
                         :wm => t.width_mobile,
                         :hm => t.height_mobile,
                         :r => t.rotate,
                         :auid => t.active_user_id ,
                         :e => t.enabled,
                         :cp => t.confirmations_pending,
                         :crid => t.customer_id,
                         :acrid => t.active_customer_id,
                         :rf => t.request_finish,
                         :rw => t.request_waiter,
                         :no => t.note
                        }
        end
        render :json => tables
      }
    end
  end

  def show
    @table = get_model
    render :nothing => true and return unless @table

    if params[:order_id] and not params[:order_id].empty?
      # route directly to the order form, even when there are 2 open orders. this is called from the room view, or from the invoice view when going back to the table view
      @order = @current_vendor.orders.existing.find_by_id(params[:order_id])
      if @order.finished == true
        render :js => "order_already_finished();"
      else
        render 'orders/render_order_form' and return
      end
      
    else
      @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => params[:id])
      if @orders.size > 1
        render_invoice_form(@table) and return
      else
        # there is only 1 open order
        @order = @orders.first
        render 'orders/render_order_form' and return
      end
    end
  end

  def new
    @table = Table.new
  end

  def create
    @current_vendor.tables.update_all :booking_table => nil if params[:table][:booking_table] == '1'
    
    permitted = params.require(:table).permit :name,
        :width,
        :height,
        :width_mobile,
        :height_mobile,
        :rotate,
        :booking_table,
        :customer_table,
        :enabled,
        :top,
        :left
        
    @table = Table.new permitted
    @table.vendor = @current_vendor
    @table.company = @current_company
    if @table.save
      # Make newly created table available to all users of all vendors of this company. This doesn't hurt because users will only see the tables of the vendor which is currently activated. u.tables is like a whitelist.
      @current_company.users.each do |u|
        u.tables << @table
      end
      flash[:notice] = t('tables.create.success')
      redirect_to tables_path
    else
      render :new
    end
  end

  def edit
    @table = get_model
    redirect_to tables_path and return unless @table
    render :new
  end

  def update
    @table = get_model
    redirect_to tables_path and return unless @table
    @current_vendor.tables.update_all :booking_table => nil if params[:table][:booking_table] == '1'
    
    permitted = params.require(:table).permit :name,
        :width,
        :height,
        :width_mobile,
        :height_mobile,
        :rotate,
        :booking_table,
        :customer_table,
        :enabled,
        :top,
        :left
    
    success = @table.update_attributes permitted
    if success
      flash[:notice] = t('tables.create.success')
      redirect_to tables_path
    else
      render :new
    end
  end

  def update_coordinates
    if params[:mobile_drag_and_drop] == 'true'
      left_attribute = :left_mobile
      top_attribute = :top_mobile
    else
      left_attribute = :left
      top_attribute = :top
    end
    @table = get_model
    @table.update_attributes(left_attribute => params[:left], top_attribute => params[:top])
    render :nothing => true
  end

  def destroy
    @table = get_model
    redirect_to tables_path and return unless @table
    if @table.active_user_id
      flash[:error] = "This table has an open order. Cannot delete."
      redirect_to tables_path
      return
    end
    @table.hide(@current_user.id)
    flash[:notice] = t('tables.destroy.success')
    redirect_to tables_path
  end

  def mobile
    @tables = @current_user.tables.existing
  end

end
