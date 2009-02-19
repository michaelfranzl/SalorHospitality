class SettlementsController < ApplicationController
  def show
  end

  def new
    @unsettled_orders = Order.find_all_by_user_id(params[:user_id])
  end

  def create
  end

end
