class RoomsController < ApplicationController
  respond_to :html,:json

  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @rooms_json = {:keys => [], :rooms => {}, :bookings => {}}
    @rooms = Room.where(:vendor_id => @current_vendor.id).existing.includes(:bookings,:room_type)
    if params[:from] then
      from_date = params[:from].to_date - 5.days
    else
      from_date = Time.now
    end
    n = Time.now + 31.days
    @rooms.each do |room|
      @rooms_json[:keys] << room.id
      @rooms_json[:rooms][room.id.to_s] = {:room => room, :room_type => room.room_type, :bookings => []}
      bookings = room.bookings.existing.where(["from_date between ? and ?",from_date,n])
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

  def new
    @room = Room.new
    @room_types = @current_vendor.room_types.existing.active
  end

  def show
    @room = get_model
    redirect_to rooms_path and return unless @room
    if params[:from] then
      from_date = params[:from].to_date - 5.days
    else
      from_date = Time.now
    end
    n = Time.now + 31.days
    @bookings = @room.bookings.existing.where(["from_date between ? and ?",from_date,n])
    if params[:booking_id] then
      @booking = Booking.where(:vendor_id => @current_vendor.id).find_by_id(params[:booking_id])
    end
    render 'bookings/go_to_booking_form'
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
