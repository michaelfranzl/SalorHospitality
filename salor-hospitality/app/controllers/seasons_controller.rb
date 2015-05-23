# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SeasonsController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @seasons = @current_vendor.seasons.existing.order(:from_date)
  end

  def new
    @season = Season.new
  end

  def create
    permitted = params.require(:season).permit :name,
      :'from_date(1i)',
      :'from_date(2i)',
      :'from_date(3i)',
      :'to_date(1i)',
      :'to_date(2i)',
      :'to_date(3i)',
      :color
    @season = Season.new permitted
    @season.vendor = @current_vendor
    @season.company = @current_company
    if @season.save
      @season.calculate_duration
      redirect_to seasons_path
    else
      render(:new)
    end
  end

  def edit
    @season = Season.accessible_by(@current_user).existing.find_by_id(params[:id])
    render :new
  end

  def update
    @season = Season.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to seasons_path and return unless @season
    permitted = params.require(:season).permit :name,
      :'from_date(1i)',
      :'from_date(2i)',
      :'from_date(3i)',
      :'to_date(1i)',
      :'to_date(2i)',
      :'to_date(3i)',
      :color
    if @season.update_attributes permitted
      @season.calculate_duration
      redirect_to(seasons_path)
    else
      render(:new)
    end
  end

  def destroy
    @season = Season.accessible_by(@current_user).existing.find_by_id(params[:id])
    redirect_to seasons_path and return unless @season
    @season.update_attribute :hidden, true
    redirect_to seasons_path
  end

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_hotel'
    end
end
