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

class StocksController < ApplicationController

  def index
    @stocks = Stock.find(:all)
  end

  def new
    @stock = Stock.new
  end

  def show
    @stock = Stock.find(params[:id])
  end

  def create
    @stock = Stock.new(params[:stock])
    @stock.save ? redirect_to(stocks_path) : render(:new)
  end

  def edit
    @stock = Stock.find(params[:id])
    render :new
  end

  def update
    @stock = Stock.find(params[:id])
    @stock.update_attributes(params[:stock]) ? redirect_to(stocks_path) : render(:new)
  end

  def destroy
    @stock = Stock.find(params[:id])
    @stock.destroy
    redirect_to stocks_path
  end

end
