# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class CostCentersController < ApplicationController
  def index
    @cost_centers = CostCenter.find(:all)
  end

  def new
    @cost_center = CostCenter.new
  end

  def create
    @cost_center = CostCenter.new(params[:cost_center])
    @cost_center.save ? redirect_to(cost_centers_path) : render(:new)
  end

  def edit
    @cost_center = CostCenter.find(params[:id])
    render :new
  end

  def update
    @cost_center = CostCenter.find(params[:id])
    @cost_center.update_attributes(params[:cost_center]) ? redirect_to(cost_centers_path) : render(:new)
  end

  def destroy
    @cost_center = CostCenter.find(params[:id])
    flash[:notice] = t(:cost_center_was_successfully_deleted, :cost_center => @cost_center.name)
    @cost_center.destroy
    redirect_to cost_centers_path
  end

end
