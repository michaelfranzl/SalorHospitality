class RoomTypesController < ApplicationController
  def index
    @room_types = @current_vendor.room_types.existing
  end

  def new
    @room_type = RoomType.new
  end

  def create
    @room_type = RoomType.new(params[:room_type])
    @room_type.vendor = @current_vendor
    @room_type.company = @current_company
    if @room_type.save
      redirect_to room_types_path
    else
      render(:new)
    end
  end

  def edit
    @room_type = RoomType.accessible_by(@current_user).existing.find_by_id(params[:id])
    render :new
  end

  def update
    @room_type = RoomType.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to room_types_path and return unless @room_type
    @room_type.update_attributes(params[:room_type]) ? redirect_to(room_types_path) : render(:new)
  end

  def destroy
    @room_type = RoomType.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to room_types_path and return unless @room_type
    @room_type.update_attribute :hidden, true
    redirect_to room_types_path
  end
end
