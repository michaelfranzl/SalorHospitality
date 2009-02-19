class OrdersController < ApplicationController

  def index
    @tables = Table.find(:all)
    @unsettled_orders = Order.find_all_by_settlement_id(nil)
    unsettled_userIDs = Array.new
    @unsettled_orders.each do |uo|
      unsettled_userIDs << uo.user_id
    end
    unsettled_userIDs.uniq!
    @unsettled_users = User.find(:all, :conditions => { :id => unsettled_userIDs })
  end

  def new
    @order = Order.new
    @order.table_id = params[:table_id]
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
    redirect_to table_orders_path
  end
end
