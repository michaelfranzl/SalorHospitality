class RoomPricesController < ApplicationController

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
    @room_price.update_attributes(params[:room_price]) ? redirect_to(room_prices_path) : render(:new)
  end

  def destroy
    @room_price = RoomPrice.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to room_prices_path and return unless @room_price
    @room_price.update_attribute :hidden, true
    redirect_to room_prices_path
  end

  def generate
    seasons = @current_vendor.seasons.existing
    room_types = @current_vendor.room_types.existing
    guest_types = @current_vendor.guest_types.existing
    seasons.each do |s|
      room_types.each do |rt|
        guest_types.each do |gt|
          unless @current_vendor.room_prices.where(:season_id => s.id, :room_type_id => rt.id, :guest_type_id => gt.id).any?
            RoomPrice.create :vendor_id => @current_vendor.id, :company_id => @current_company.id, :season_id => s.id, :room_type_id => rt.id, :guest_type_id => gt.id, :base_price => 0
          end
        end
      end
    end
    redirect_to room_prices_path
  end
end
