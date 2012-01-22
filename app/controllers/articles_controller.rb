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
 
  # tested
  def index
    @scopes = ['active','waiterpad']
    @articleshash = build_articleshash(@scopes)
    @categories = @current_vendor.categories.positioned
    respond_to do |wants|
      wants.html
      wants.js { send_data @current_vendor.cache, :content_type => 'text/javascript', :disposition => 'inline' }
    end
  end

  # tested
  def active
    @categories = @current_vendor.categories.positioned
  end

  # tested
  def waiterpad
    @categories = @current_vendor.categories.positioned
  end

  # tested
  def update_cache
    @categories = @current_vendor.categories.positioned
    @scopes = ['menucard','waiterpad']
    @current_vendor.update_attribute :cache, render_to_string('articles/index.js')
    flash[:notice] = t('articles.cache_successfully_updated')
    redirect_to orders_path
  end

  # tested
  def listall
    @articles = Article.accessible_by(@current_user).existing.order('name, description, price')
  end

  # tested
  def new
    @article = Article.new
    @categories = @current_vendor.categories.positioned
  end

  # tested
  def create
    @article = Article.new(params[:article])
    if @article.save
      @article.company = @current_company
      @article.vendor = @current_vendor
      @article.save
      redirect_to articles_path
      flash[:notice] = t('articles.create.success')
    else
      @categories = @current_vendor.categories.positioned
      flash[:error] = t('articles.create.failure')
      render :new
    end
  end

  # tested
  def edit
    @categories = @current_vendor.categories.positioned
    session[:return_to] = /.*?\/\/.*?(\/.*)/.match(request.referer)[1] if request.referer
    @article = get_model
    @article ? render(:new) : redirect_to(articles_path)
  end

  # tested
  def update
    @article = get_model
    redirect_to articles_path and return unless @article
    @article.update_attributes params[:article]
    @categories = @current_vendor.categories
    if @article.save
      flash[:notice] = t('articles.update.success')
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        redirect_to orders_path
      end
    else
      flash[:error] = t('articles.update.failure')
      render :new
    end
  end

  # tested
  def destroy
    @article = get_model
    redirect_to articles_path and return if not @article
    @article.hide
    flash[:notice] = t('articles.destroy.success')
    redirect_to articles_path
  end

  # tested
  def find
    if params['articles_search_text'].strip.length > 2
      search_terms = params['articles_search_text'].split.collect { |word| "%#{ word.downcase }%" }
      conditions = search_terms.collect{ |t| "LOWER(name) LIKE '#{ t }'" }.join(' AND ')
      @found_articles = Article.accessible_by(@current_user).existing.where(conditions).limit(5).order('name ASC')
    else
      render :nothing => true
    end
  end

  # tested
  def change_scope
    @article = get_model
    return if not @article
    @source = params[:source]
    @target = params[:target]
    if @target == 'searchresults' and @source != 'searchresults'
      @article.update_attribute @source.to_sym, false
      @articleshash = build_articleshash([@source])
      @target = nil
    elsif @target == @source
      render :nothing => true
    else
      @article.update_attribute @target.to_sym, true
      @articleshash = build_articleshash([@target])
      @source = nil
    end
    @categories = @current_vendor.categories.positioned
  end

  # testing not automatable
  def sort
    params['article'].each do |id|
      a = Article.accessible_by(@current_user).find_by_id id
      a.position = params['article'].index(a.id.to_s) + 1
      a.save
    end
    render :nothing => true
  end

  # tested
  def sort_index
    @categories = @current_vendor.categories.positioned
  end

  private

  def build_articleshash(scopes)
    articleshash = {}
    articles = @current_vendor.articles
    scopes.each do |s|
      articleshash.merge! s => {}
      articles.each do |a|
        next unless a.respond_to?(s.to_sym) and a.send(s.to_sym)
        articleshash[s][a.category_id] = []
        articleshash[s][a.category_id] << a
      end
    end
    articleshash
  end
end
