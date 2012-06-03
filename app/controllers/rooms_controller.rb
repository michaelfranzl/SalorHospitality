class RoomsController < ApplicationController
  def index
    @rooms = @current_vendor.rooms.existing
  end

  def new
    @room = Room.new
    @room_types = @current_vendor.room_types.existing.active
  end

  def show
    @room = get_model
    redirect_to user_path and return unless @room
  end

  def create
    @room = Room.new(params[:room])
    @room.vendor = @current_vendor
    @room.company = @current_company
    if @room.save
      flash[:notice] = I18n.t("rooms.create.success")
      redirect_to rooms_path
    else
      @room_types = @current_vendor.room_types.existing.active
      render(:new)
    end
  end

  def edit
    @room = Room.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to user_path and return unless @room
    @room_types = @current_vendor.room_types.existing.active
    render :new
  end

  def update
    @room = Room.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to user_path and return unless @room
    if @room.update_attributes(params[:room])
      flash[:notice] = I18n.t("rooms.create.success")
      redirect_to(rooms_path)
    else
      @room_types = @current_vendor.room_types.existing.active
      render(:new)
    end
  end

  def destroy
    @room = Room.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to user_path and return unless @room
    flash[:notice] = I18n.t("rooms.destroy.success")
    @room.update_attribute :hidden, true
    redirect_to rooms_path
  end
end
