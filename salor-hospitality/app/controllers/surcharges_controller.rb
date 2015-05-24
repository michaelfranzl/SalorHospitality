# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SurchargesController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    season_ids = @current_vendor.seasons.existing.collect { |s| s.id }
    guest_type_ids = @current_vendor.guest_types.collect{ |gt| gt.id }
    guest_type_ids << nil
    
    @surcharges = @current_vendor.surcharges.existing.where(:season_id => season_ids, :guest_type_id => guest_type_ids)
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
    permitted = params.require(:surcharge).permit :name,
      :radio_select,
      :selected,
      :visible,
      :tax_amounts_attributes => [
        :amount,
        :tax_id,
        :hidden,
        :id
      ]
    
    success = @surcharge.update_attributes permitted
    if success and not @surcharge.tax_amounts.where(:tax_id => nil).any?
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
