# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
