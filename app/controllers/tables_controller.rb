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

class TablesController < ApplicationController

  def index
    @tables = @current_user.tables.existing
    @last_finished_order = Order.find_all_by_finished(true).last
    respond_to do |wants|
      wants.html
      wants.js
    end
  end

  def show
    @table = Table.accessible_by(@current_user).find_by_id params[:id]
    @cost_centers = CostCenter.find_all_by_active(true)
    @taxes = Tax.accessible_by @current_user

    @orders = Order.accessible_by(@current_user).where(:table_id => @table.id, :finished => false )
    if @orders.size > 1
      render 'orders/go_to_invoice_form'
    else
      @order = @orders.first
      render 'orders/go_to_order_form'
    end
  end

  def new
    @table = Table.new
  end

  def create
    @table = Table.new(params[:table])
    @table.save ? redirect_to(tables_path) : render(:new)
  end

  def edit
    @table = Table.scopied.find(params[:id])
    render :new
  end

  def update
    @table = Table.scopied.find(params[:id])
    success = @table.update_attributes(params[:table])
    respond_to do |wants|
      wants.html{ success ? redirect_to(tables_path) : render(:new)}
      wants.js { render :nothing => true }
    end
  end

  def destroy
    @table = Table.scopied.find(params[:id])
    @table.update_attribute :hidden, true
    redirect_to tables_path
  end

  def time_range
    @from = Date.civil( params[:from][:year ].to_i,
                        params[:from][:month].to_i,
                        params[:from][:day  ].to_i) if params[:from]
    @to =   Date.civil( params[:to  ][:year ].to_i,
                        params[:to  ][:month].to_i,
                        params[:to  ][:day  ].to_i) if params[:to]
    @tables = Table.scopied.find(:all)
    render :index
  end

  def mobile
    @tables = @current_user.tables
  end

end
