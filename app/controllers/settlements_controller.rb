class SettlementsController < ApplicationController
  def index
    @settlements = Settlement.all
    @taxes = Tax.all
  end

  def show
    @settlement = Settlement.find(params[:id])
    @settlement_orders = Order.find_all_by_settlement_id(@settlement.id)
    render :new
  end

  def new
    @settlement = Settlement.new
    @settlement.user_id = params[:user_id]
    @settlement_orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true })
  end

  def create
    @settlement = Settlement.new(params[:settlement])
    @settlement.user_id = params[:user_id]
    @settlement_orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true })
    if @settlement.save
      @settlement_orders.each do |so|
        so.settlement_id = @settlement.id
        so.save
      end
      redirect_to orders_path
    else
      render :new
    end
  end

end
