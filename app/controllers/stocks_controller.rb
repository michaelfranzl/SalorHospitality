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
