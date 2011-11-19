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

  skip_before_filter :fetch_logged_in_user, :image

  def index
    @categories = Category.existing
    @scopes = ['menucard','waiterpad']
    @articles = Article.all
    respond_to do |wants|
      wants.html
      wants.js {
        send_data @current_company.cache, :content_type => 'text/javascript', :disposition => 'inline'
      }
    end
  end

  def update_cache
    @categories = Category.find(:all, :order => 'position')
    @scopes = ['menucard','waiterpad']
    @articles = Article.all
    #File.open('test.txt','w') { |f| f.write render_to_string 'articles/index.js' }
    @current_company.update_attribute :cache, render_to_string('articles/index.js')
    redirect_to orders_path
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
    @article.save ? redirect_to(articles_path) : render(:new)
  end

  def edit
    @article = Article.find(params[:id])
    @groups = Group.find(:all, :order => 'name ASC')
    @quantities = Quantity.where(:article_id => params[:id], :hidden => false)
    session[:return_to] = /.*?\/\/.*?(\/.*)/.match(request.referer)[1] if request.referer
    render :new
  end

  def update
    @categories = Category.find(:all, :order => 'position')
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
    @article.update_attribute :hidden, true
    redirect_to articles_path
  end

  def find
    if params['articles_search_text'].strip.length > 2
      search_terms = params['articles_search_text'].split.collect { |word| "%#{ word.downcase }%" }
      conditions = 'hidden = false AND '
      conditions += (["(LOWER(name) LIKE ?)"] * search_terms.size).join(' AND ')
      @found_articles = Article.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 5 )
      #render :partial => 'find', :layout => false
    else
      render :nothing => true
    end
  end

  def change_scope
    @categories = Category.find(:all, :order => 'position')
    @article = Article.find(/([0-9]*)$/.match(params[:id])[1])

    @drag_from = /[^_]*/.match(params[:id])[0]
    if params[:scope] == 'remove'
      @article.update_attribute @drag_from.to_sym, false
      render :nothing => true
    elsif @drag_from == params[:scope]
      render :nothing => true
    else
      @drag_to = params[:scope]
      @article.update_attribute @drag_to.to_sym, true
    end
  end

  def sort
    params['article'].each do |id|
      a = Article.find_by_id id
      a.position = params['article'].index(a.id.to_s) + 1
      a.save
    end
    render :nothing => true
  end

  def sort_index
    @categories = Category.all
  end
  
  def image
    @article = Article.find_by_id params[:id]
    send_data @article.image, :type => @article.image_content_type, :disposition => 'inline'
  end

end
