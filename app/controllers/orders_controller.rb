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

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(params[:order])
    @order.table_id = params[:table_id]
    if @order.save
      if @order.finished
        reduce_stocks(@order)
        redirect_to @order
      else
        redirect_to(orders_path)
      end
    else
      render(:new)
    end
  end

  def edit
    @order = Order.find(params[:id])
    render :new
  end

  def update
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      if @order.finished
        reduce_stocks(@order)
        redirect_to @order
      else
        redirect_to orders_path
      end
    else
      render(:new)
    end
  end

  def destroy
    @order = Order.find(params[:id])
    flash[:notice] = "Die Bestellung \"#{ @order.name }\" wurde erfolgreich geloescht."
    @order.destroy
    redirect_to table_orders_path
  end

  private

    def reduce_stocks(order)
      order.items.each do |item|
        item.article.ingredients.each do |ingredient|
          ingredient.stock.balance -= item.count * ingredient.amount
          ingredient.stock.save
        end
      end
    end
end
