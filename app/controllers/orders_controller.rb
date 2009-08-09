class OrdersController < ApplicationController

  def index
    @tables = Table.find(:all)
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
    @categories = Category.all
    @order.table_id = params[:table_id]
  end

  def edit
    @order = Order.find(params[:id])
    @categories = Category.all
    render :new
  end

  def create
    @order = Order.new(params[:order])
    @categories = Category.all
    @order.table_id = params[:table_id]
    @order.sum = calculate_order_sum @order
    @order.save ? process_order(@order) : render(:new)
  end

  def update
    @order = Order.find(params[:id])
    @categories = Category.all
    @order.update_attribute( :sum, calculate_order_sum(@order) )
    @order.update_attributes(params[:order]) ? process_order(@order) : render(:new)
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

    def make_partial_order(order, items_for_partial_order)
      partial_order = order.clone
      if partial_order.save
        items_for_partial_order.each do |item|
          item.update_attribute :order_id, partial_order.id
        end
      else
        flash[:error] = 'Partial Order could not be saved.'
      end
      Item.update_all :partial_order => false
      partial_order
    end

    def process_order(order)
      items_for_partial_order = Item.find_all_by_partial_order(true)
      partial_order = make_partial_order(order, items_for_partial_order) if !items_for_partial_order.empty?
      if order.finished
        reduce_stocks order
        redirect_to order_path order
      else
        partial_order ? redirect_to(edit_order_path(partial_order)) : redirect_to(orders_path)
      end
    end

    def calculate_order_sum(order)
      subtotal = 0
      order.items.each do |item|
        c = item.count
        p = item.article.price
        if !item.free
          sum = c * p
          subtotal += c * p
        end
      end
      return subtotal
    end

end
