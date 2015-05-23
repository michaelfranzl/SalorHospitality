# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class PaymentMethodsController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @payment_methods = @current_vendor.payment_methods.existing
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def create
    permitted = params.require(:payment_method).permit :name,
        :cash,
        :change
    @payment_method = PaymentMethod.new permitted
    @payment_method.vendor = @current_vendor
    @payment_method.company = @current_company
    if @payment_method.save
      flash[:notice] = t('payment_methods.create.success')
      redirect_to payment_methods_path
    else
      render :new
    end
  end

  def edit
    @payment_method = get_model
    redirect_to roles_path and return unless @payment_method
    render :new
  end

  def update
    @payment_method = get_model
    redirect_to roles_path and return unless @payment_method
    permitted = params.require(:payment_method).permit :name,
        :cash,
        :change
    if @payment_method.update_attributes permitted
      flash[:notice] = t('payment_methods.create.success')
      redirect_to(payment_methods_path)
    else
      render(:new)
    end
  end

  def destroy
    @payment_method = get_model
    redirect_to roles_path and return unless @payment_method
    @payment_method.hide(@current_user.id)
    flash[:notice] = t('payment_methods.destroy.success')
    redirect_to payment_methods_path
  end
end
