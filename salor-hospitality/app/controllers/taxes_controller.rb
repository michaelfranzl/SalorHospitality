# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class TaxesController < ApplicationController

  before_filter :check_permissions

  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @taxes = @current_vendor.taxes.existing
  end

  def new
    @tax = Tax.new
  end

  def create
    permitted = params.require(:tax).permit :name,
        :letter,
        :color,
        :include_in_statistics,
        :statistics_in_category
        
    @tax = Tax.new permitted
    @tax.vendor = @current_vendor
    @tax.company = @current_company
    if @tax.save
      redirect_to taxes_path
    else
      render(:new)
    end
  end

  def edit
    @tax = get_model
    render :new
  end

  def update
    @tax = get_model
    redirect_to taxes_path and return unless @tax
    permitted = params.require(:tax).permit :name,
        :letter,
        :color,
        :include_in_statistics,
        :statistics_in_category
    
    if @tax.update_attributes permitted
      redirect_to(taxes_path)
    else
      render(:new)
    end
  end

  def destroy
    @tax = get_model
    redirect_to taxes_path and return unless @tax
    if @tax.articles.existing.any?
      flash[:error] = "Cannot delete this tax because Articles use it."
      redirect_to taxes_path
      return
    end
    @tax.hide(@current_user.id)
    redirect_to taxes_path
  end

end
