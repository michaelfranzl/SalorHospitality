class GuestTypesController < ApplicationController
  def index
    @guest_types = @current_vendor.guest_types.existing
  end

  def new
    @guest_type = GuestType.new
    @taxes = @current_vendor.taxes.existing
  end

  def create
    @guest_type = GuestType.new(params[:guest_type])
    @guest_type.vendor = @current_vendor
    @guest_type.company = @current_company
    if @guest_type.save
      redirect_to guest_types_path
    else
      render(:new)
    end
  end

  def edit
    @guest_type = GuestType.accessible_by(@current_user).existing.find_by_id(params[:id])
    @taxes = @current_vendor.taxes.existing
    @selected_taxes = @guest_type.taxes
    render :new
  end

  def update
    @guest_type = GuestType.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to guest_types_path and return unless @guest_type
    @guest_type.update_attributes(params[:guest_type]) ? redirect_to(guest_types_path) : render(:new)
  end

  def destroy
    @guest_type = GuestType.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to guest_types_path and return unless @guest_type
    @guest_type.update_attribute :hidden, true
    redirect_to guest_types_path
  end
end
