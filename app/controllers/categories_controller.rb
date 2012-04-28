# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

class CategoriesController < ApplicationController
  def index
    @categories = Category.existing
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])
    @category.save ? redirect_to(categories_path) : render(:new)
  end

  def edit
    @category = Category.find(params[:id])
    render :new
  end

  def update
    @category = Category.find(params[:id])
    @category.update_attributes(params[:category]) ? redirect_to(categories_path) : render(:new)
  end

  def destroy
    @category = Category.find(params[:id])
    @category.update_attribute :hidden, true
    redirect_to categories_path
  end

  def sort
    @categories = Category.all
    @categories.each do |c|
      c.position = params['category'].index(c.id.to_s) + 1
      c.save
    end
  render :nothing => true
  end

end
