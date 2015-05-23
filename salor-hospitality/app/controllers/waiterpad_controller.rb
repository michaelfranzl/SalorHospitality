# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
    @current_vendor.articles.exisiting.where(:waiterpad => true).each do |article|
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
