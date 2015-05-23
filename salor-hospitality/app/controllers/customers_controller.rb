# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class CustomersController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    respond_to do |wants|
      wants.html
      wants.csv
    end
  end

  def new
    if defined?(ShSaas) == 'constant'
      redirect_to sh_saas.new_customer_path and return
    end
    @customer = Customer.new
    @customer.language = @current_user.language
    @tables = @current_vendor.tables.existing
  end

  def edit
    if defined?(ShSaas) == 'constant'
      redirect_to sh_saas.edit_customer_path and return
    end
    @customer = get_model
    @tables = @current_vendor.tables.existing
    redirect_to customers_path and return unless @customer
    render :new
  end

  def create
    permitted = params.require(:customer).permit :email,
        :password,
        :default_table_id,
        :language,
        :first_name,
        :last_name,
        :company_name,
        :address,
        :city,
        :state,
        :country,
        :postalcode,
        :m_number,
        :telephone,
        :cellphone,
        :tax_info
    @customer = Customer.new permitted
    @customer.company = @current_company
    @customer.vendor = @current_vendor
    if @customer.save
      flash[:notice] = t('customers.create.success')
      redirect_to customers_path
    else
      @tables = @current_vendor.tables.existing
      render :action => 'new'
    end
  end

  def update
    @customer = get_model
    redirect_to customers_path and return unless @customer
    permitted = params.require(:customer).permit :email,
        :password,
        :default_table_id,
        :language,
        :first_name,
        :last_name,
        :company_name,
        :address,
        :city,
        :state,
        :country,
        :postalcode,
        :m_number,
        :telephone,
        :cellphone,
        :tax_info
    
    if @customer.update_attributes permitted
      flash[:notice] = t('customers.create.success')
      redirect_to customers_path
    else
      @tables = @current_vendor.tables.existing
      render :action => 'new'
    end
  end

  def destroy
    @customer = get_model
    redirect_to customers_path and return unless @customer
    @customer.update_attribute :hidden, true
    flash[:notice] = t('customers.destroy.success')
    redirect_to customers_path
  end
end
