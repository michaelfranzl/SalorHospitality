# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class CategoriesController < ApplicationController
  
  def index
    @categories = Category.accessible_by(@current_user).existing.order("position ASC")
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(Category.process_custom_icon(params[:category]))
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
    @category = Category.accessible_by(@current_user).find(params[:id])
    render :new
  end

  def update
    @category = @permitted_model
    if @category.update_attributes(Category.process_custom_icon(params[:category])) then
      flash[:notice] = I18n.t("categories.update.success")
      redirect_to(categories_path)
    else
      render(:new)
    end
  end

  def destroy
    @category = @permitted_model
    @category.update_attribute(:hidden, true) if @category
    redirect_to categories_path
  end

  def sort
    @categories = Category.accessible_by(@current_user).where("id IN (#{params[:category].join(',')})")
    Category.sort(@categories,params[:category])
    render :nothing => true
  end

end
