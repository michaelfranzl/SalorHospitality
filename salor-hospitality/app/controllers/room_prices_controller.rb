# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class RoomPricesController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @room_prices = @current_vendor.room_prices.existing
    @seasons = @current_vendor.seasons.existing
    @guest_types = @current_vendor.guest_types.existing
    @room_types = @current_vendor.room_types.existing
  end

  def new
    @room_price = RoomPrice.new
    @room_types = @current_vendor.room_types.existing
    @guest_types = @current_vendor.guest_types.existing
    @seasons = @current_vendor.seasons.existing
  end

  def create
    @room_price = RoomPrice.new(params[:room_price])
    @room_price.vendor = @current_vendor
    @room_price.company = @current_company
    if @room_price.save
      redirect_to room_prices_path
    else
      render(:new)
    end
  end

  def edit
    @room_price = RoomPrice.accessible_by(@current_user).existing.find_by_id(params[:id])
    @room_types = @current_vendor.room_types.existing
    @guest_types = @current_vendor.guest_types.existing
    @seasons = @current_vendor.seasons.existing
    render :new
  end

  def update
    @room_price = RoomPrice.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to room_prices_path and return unless @room_price
    permitted = params.require(:room_price).permit :base_price
    if @room_price.update_attributes permitted
      redirect_to(room_prices_path)
    else
      render(:new)
    end
  end

  def destroy
    @room_price = RoomPrice.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to room_prices_path and return unless @room_price
    @room_price.update_attribute :hidden, true
    redirect_to room_prices_path
  end

  def generate
    RoomPrice.generate(@current_vendor)
    redirect_to room_prices_path
  end

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_hotel'
    end
end
