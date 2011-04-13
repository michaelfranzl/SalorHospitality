# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class ArticlesController < ApplicationController

  def index
    @categories = Category.find(:all, :order => 'sort_order')
    @scopes = ['menucard','waiterpad']
    @articles = Article.all
    respond_to do |wants|
      wants.html
      wants.js
    end
  end

  def listall
    @articles = Article.find(:all, :order => 'name, description, price', :conditions => { :hidden => false })
  end

  def new
    @article = Article.new
    @groups = Group.find(:all, :order => 'name ASC')
  end

  def create
    @article = Article.new(params[:article])
    @groups = Group.find(:all, :order => 'name ASC')
    respond_to do |wants|
      wants.html { @article.save ? redirect_to(articles_path) : render(:new) }
      wants.js do
        @id = params[:id]
        @article.save
        @foods_in_menucard = Article.find(:all, :conditions => { :menucard => true, :category_id => 1..3 }).size
      end
    end
  end

  def edit
    @article = Article.find(params[:id])
    @groups = Group.find(:all, :order => 'name ASC')
    session[:return_to] = /.*?\/\/.*?(\/.*)/.match(request.referer)[1] if request.referer
    render :new
  end

  def update
    @categories = Category.find(:all, :order => 'sort_order')
    @article = Article.find_by_id params[:id]
    @article.update_attributes params[:article]

    if @article.hidden
      @article.quantities.existing.each do |q|
        q.update_attribute :hidden, true
      end
    end

    if @article.save
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        redirect_to orders_path
      end
    else
      render :new
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    redirect_to articles_path
  end

  def find
    if params['articles_search_text'].strip.length > 2
      search_terms = params['articles_search_text'].split.collect { |word| "%#{ word.downcase }%" }
      conditions = 'hidden = false AND '
      conditions += (["(LOWER(name) LIKE ?)"] * search_terms.size).join(' AND ')
      @found_articles = Article.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 5 )
      render :partial => 'find', :layout => false
    else
      render :nothing => true
    end
  end

  def change_scope
    @categories = Category.find(:all, :order => 'sort_order')
    @article = Article.find(/([0-9]*)$/.match(params[:id])[1])

    if params[:scope] == 'remove'
      @scope_of_dragged_article = /[^_]*/.match(params[:id])[0]
      @article.update_attribute @scope_of_dragged_article.to_sym, false
    else
      @scope_of_dragged_article = params[:scope]
      @article.update_attribute @scope_of_dragged_article.to_sym, true
    end
  end

end
