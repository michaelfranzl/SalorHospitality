# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class WaiterpadController < ApplicationController

  def index
    @categories = @current_vendor.categories.existing.active.positioned
  end

  def edit
    @waiterpad = {}
    @categories = @current_vendor.categories.existing.active.positioned
    @categories.each do |category|
      articles = {}
      category.articles.existing.active.positioned.each do |article|
        articles = articles.merge({ "#{article.name} | #{article.description}" => article.id })
      end
      @waiterpad = @waiterpad.merge({ category.name => articles })
    end

    @selected = []
    @current_vendor.articles.exisiting.find_all_by_waiterpad(true).each do |article|
      @selected << article.id
    end
  end

  def update
    @current_vendor.articles.exisiting.update_all :waiterpad => 0
    params[:waiterpad].each do |article_id|
      @current_vendor.articles.find(article_id).update_attribute :waiterpad, true
    end
    redirect_to orders_path
  end

end
