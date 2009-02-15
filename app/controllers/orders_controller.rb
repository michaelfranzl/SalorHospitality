class OrdersController < ApplicationController

  def index
    @tables = Table.find(:all)
    #@users = User.find(:all)
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(params[:order])
    @order.save ? redirect_to(orders_path) : render(:new)
  end

  def edit
    @order = Order.find(params[:id])
    render :new
  end

  def update
    @order = Order.find(params[:id])
    @order.update_attributes(params[:order]) ? redirect_to(orders_path) : render(:new)
  end

  def destroy
    @order = Order.find(params[:id])
    flash[:notice] = "Die Bestellung \"#{ @order.name }\" wurde erfolgreich geloescht."
    @order.destroy
    redirect_to orders_path
  end
end
