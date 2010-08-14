class TaxesController < ApplicationController
  def index
    @taxes = Tax.find(:all)
  end

  def new
    @tax = Tax.new
  end

  def create
    @tax = Tax.new(params[:tax])
    @tax.save ? redirect_to(taxes_path) : render(:new)
  end

  def edit
    @tax = Tax.find(params[:id])
    render :new
  end

  def update
    @tax = Tax.find(params[:id])
    @tax.update_attributes(params[:tax]) ? redirect_to(taxes_path) : render(:new)
  end

  def destroy
    @tax = Tax.find(params[:id])
    @tax.destroy
    redirect_to taxes_path
  end

end
