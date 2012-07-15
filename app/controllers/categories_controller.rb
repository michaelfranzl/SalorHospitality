# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class CategoriesController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy', 'sort']
  
  def index
    @categories = @current_vendor.categories.existing.positioned
  end

  def new
    @category = Category.new
    @taxes = @current_vendor.taxes.existing
    @users = @current_vendor.users.existing.active
    @printers = @current_vendor.vendor_printers.existing
  end

  def create
    if @current_vendor.max_categories and @current_vendor.max_categories < @current_vendor.categories.existing.count
      flash[:notice] = t('categories.create.license_limited', :count => @current_vendor.max_categories)
      redirect_to categories_path and return
    end
    @category = Category.new(Category.process_custom_icon(params[:category]))
    @taxes = @current_vendor.taxes.existing
    @users = @current_vendor.users.existing.active
    @printers = @current_vendor.vendor_printers.existing
    @category.vendor = @current_vendor
    @category.company = @current_company
    if @category.save then
      flash[:notice] = I18n.t("categories.create.success")
      redirect_to(categories_path)
    else
      render :new
    end
  end

  def edit
    @category = get_model
    redirect_to roles_path and return unless @category
    @taxes = @current_vendor.taxes.existing
    @users = @current_vendor.users.existing.active
    @printers = @current_vendor.vendor_printers.existing
    render :new
  end

  def update
    @category = get_model
    redirect_to roles_path and return unless @category
    if @category.update_attributes(Category.process_custom_icon(params[:category])) then
      flash[:notice] = I18n.t("categories.create.success")
      redirect_to categories_path
    else
      @taxes = @current_vendor.taxes.existing
      @users = @current_vendor.users.existing.active
      @printers = @current_vendor.vendor_printers.existing
      render :new
    end
  end

  def destroy
    @category = get_model
    redirect_to roles_path and return unless @category
    @category.update_attribute :hidden, true
    flash[:notice] = t('categories.destroy.success')
    redirect_to categories_path
  end

  def sort
    @categories = @current_vendor.categories.existing.active.where("id IN (#{params[:category].join(',')})")
    Category.sort(@categories,params[:category])
    render :nothing => true
  end

end
