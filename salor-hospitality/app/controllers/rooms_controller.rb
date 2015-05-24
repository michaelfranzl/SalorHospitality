# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class RoomsController < ApplicationController
  respond_to :html,:json

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @rooms_json = {:keys => [], :rooms => {}, :bookings => {}}
    @rooms = @current_vendor.rooms.existing.includes(:bookings,:room_type)
    if params[:from] then
      from_date = params[:from].to_date - 31.days
      n = params[:from].to_date + 31.days
    else
      from_date = Time.now
      n = Time.now + 31.days
    end
    
    
    @rooms.each do |room|
      @rooms_json[:keys] << room.id
      @rooms_json[:rooms][room.id.to_s] = {:room => room, :room_type => room.room_type, :bookings => []}
      bookings = room.bookings.existing.where(["from_date between ? and ?", from_date,n])
      bookings.each do |booking|
        @rooms_json[:rooms][room.id.to_s][:bookings] << booking.id
        @rooms_json[:bookings][booking.id.to_s] = booking
      end
    end
    respond_with(@rooms) do |format|
      format.html
      format.json { render :json => @rooms_json}
    end
  end
  
  def show
    @room = get_model
    redirect_to rooms_path and return unless @room
    render 'bookings/go_to_booking_form'
  end


  def new
    @room = Room.new
    @room_types = @current_vendor.room_types.existing.active
  end

  def create
    permitted = params.require(:room).permit :name, :room_type_id
    @room = Room.new permitted
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
    
    permitted = params.require(:room).permit :name, :room_type_id
    
    if @room.update_attributes permitted
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

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_hotel'
    end
end
