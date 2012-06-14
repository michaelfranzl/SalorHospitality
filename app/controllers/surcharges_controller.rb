class SurchargesController < ApplicationController

  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @surcharges = @current_vendor.surcharges.existing
    @guest_types = @current_vendor.guest_types.existing
    @guest_types << nil
    @seasons = @current_vendor.seasons.existing
    @surcharge_names = @surcharges.collect{ |s| s.name }.uniq
    @surcharge_names << nil
  end

  def new
    @surcharge = Surcharge.new
    @guest_types = @current_vendor.guest_types.existing
    @seasons = @current_vendor.seasons.existing
    @taxes = @current_vendor.taxes.existing
  end

  def create
    guest_types = @current_vendor.guest_types.existing
    seasons = @current_vendor.seasons.existing
    seasons.each do |s|
      guest_types.each do |gt|
        gt_id = params[:common_surcharge] ? nil : gt.id 
        @surcharge = @current_vendor.surcharges.where(:season_id => s.id, :guest_type_id => gt_id, :name => params[:surcharge][:name]).first
        unless @surcharge
          @surcharge = Surcharge.create :season_id => s.id, :guest_type_id => gt_id, :name => params[:surcharge][:name], :vendor_id => @current_vendor.id, :company_id => @current_vendor.company.id, :radio_select => params[:surcharge][:radio_select]
        end
      end
    end
    redirect_to surcharges_path
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
