class SettlementsController < ApplicationController
  def index
    @settlements = Settlement.all
    @taxes = Tax.all

    @unsettled_orders = Order.find(:all, :conditions => { :settlement_id => nil, :finished => true })
    unsettled_userIDs = Array.new
    @unsettled_orders.each do |uo|
      unsettled_userIDs << uo.user_id
    end
    unsettled_userIDs.uniq!
    @unsettled_users = User.find(:all, :conditions => { :id => unsettled_userIDs })
  end

  def show
    @settlement = Settlement.find(params[:id])
    @orders = Order.find_all_by_settlement_id(@settlement.id)
    render :new
  end

  def new
    @settlement = Settlement.new
    @settlement.user_id = params[:user_id]
    @orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true })
  end

  def edit
    @settlement = Settlement.find(params[:id])
    @orders = Order.find_all_by_settlement_id(@settlement.id)
    render :new
  end

  def update
    @settlement = Settlement.find(params[:id])
    @settlement.update_attributes(params[:settlement])
    redirect_to settlements_path
  end

  def create
    @settlement = Settlement.new(params[:settlement])
    @settlement.user_id = params[:user_id]
    @orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true })
    if @settlement.save
      @orders.each do |so|
        so.settlement_id = @settlement.id
        so.save
      end
      redirect_to settlements_path
    else
      render :new
    end
  end

end
