class SurchargesController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @surcharges = @current_vendor.surcharges.existing
    @surcharge_names = @surcharges.collect{ |s| s.name }.uniq
    @surcharge_names << nil
    @seasons = @current_vendor.seasons.existing
    @guest_types = @current_vendor.guest_types.existing
    @guest_types << nil
  end

  def new
    @surcharge = Surcharge.new
    @guest_types = @current_vendor.guest_types.existing
    @seasons = @current_vendor.seasons.existing
    @taxes = @current_vendor.taxes.existing
  end

  def create
    Surcharge.create_including_all_relations @current_vendor, params
    redirect_to surcharges_path
  end

  def edit
    @surcharge = get_model
    @guest_types = @current_vendor.guest_types.existing
    @seasons = @current_vendor.seasons.existing
    @taxes = @current_vendor.taxes.existing
    render :new
  end

  def update
    @surcharge = get_model
    redirect_to surcharges_path and return unless @surcharge
    old_name = @surcharge.name
    if @surcharge.update_attributes(params[:surcharge])
      @surcharge.update_all_relations params, old_name
      @surcharge.calculate_totals
      redirect_to(surcharges_path)
    else
      @taxes = @current_vendor.taxes.existing
      render(:new)
    end
  end

  def destroy
    @surcharge = Surcharge.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to surcharges_path and return unless @surcharge
    @surcharge.delete_including_all_relations @current_vendor
    redirect_to surcharges_path
  end

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_hotel'
    end
end
