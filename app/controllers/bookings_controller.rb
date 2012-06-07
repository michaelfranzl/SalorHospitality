class BookingsController < ApplicationController
  def show
    if params[:id] != 'last'
      @booking = @current_vendor.bookings.existing.find(params[:id])
    else
      @booking = @current_vendor.bookings.existing.find_all_by_finished(true).last
    end
    redirect_to '/' and return if not @booking
    @previous_booking, @next_booking = neighbour_models('bookings', @booking)
    respond_to do |wants|
      wants.html
      wants.bill { render :text => generate_escpos_invoice(@booking) }
    end
  end
end
