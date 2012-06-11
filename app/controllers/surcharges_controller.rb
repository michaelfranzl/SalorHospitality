class SurchargesController < ApplicationController
  def index
    @surcharges = @current_vendor.surcharges.existing
  end

  def new
    @surcharge = Surcharge.new
    @guest_types = @current_vendor.guest_types.existing
    @seasons = @current_vendor.seasons.existing
    @taxes = @current_vendor.taxes.existing
  end

  def create
    @surcharge = Surcharge.new(params[:surcharge])
    @surcharge.vendor = @current_vendor
    @surcharge.company = @current_company
    if @surcharge.save
      @surcharge.calculate_totals
      redirect_to surcharges_path
    else
      @seasons = @current_vendor.seasons.existing
      @taxes = @current_vendor.taxes.existing
      @guest_types = @current_vendor.guest_types.existing
      render(:new)
    end
  end

  def edit
    @surcharge = Surcharge.accessible_by(@current_user).existing.find_by_id(params[:id])
    @guest_types = @current_vendor.guest_types.existing
    @seasons = @current_vendor.seasons.existing
    @taxes = @current_vendor.taxes.existing
    render :new
  end

  def update
    @surcharge = Surcharge.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to surcharges_path and return unless @surcharge
    if @surcharge.update_attributes(params[:surcharge])
      @surcharge.calculate_totals
      if params[:surcharge][:radio_select] == '1'
        @surcharge.update_attribute(:radio_select, true)
      else
        @surcharge.update_attribute(:radio_select, false)
      end
      redirect_to(surcharges_path)
    else
      @taxes = @current_vendor.taxes.existing
      render(:new)
    end
  end

  def destroy
    @surcharge = Surcharge.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to surcharges_path and return unless @surcharge
    @surcharge.update_attribute :hidden, true
    redirect_to surcharges_path
  end
end
