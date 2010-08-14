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
