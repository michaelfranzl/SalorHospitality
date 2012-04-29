# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class MenucardController < ApplicationController

  def index
    @categories = Category.all
  end

  def update
    Article.update_all :menucard => 0
    params[:menucard].each do |article_id|
      Article.find(article_id).update_attribute :menucard, true
    end
    redirect_to orders_path
  end

end
