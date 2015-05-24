# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class ArticlesController < ApplicationController

  after_filter :update_vendor_cache, :only => ['create','update','destroy', 'change_scope', 'sort']
 
  # tested
  def index
    @scopes = ['active', 'inactive']
    @articleshash = build_articleshash(@scopes)
    @categories = @current_vendor.categories.existing.active.positioned
    @statistic_categories = @current_vendor.statistic_categories.existing
    respond_to do |wants|
      wants.html
      wants.js { send_data @current_vendor.cache, :content_type => 'text/javascript', :disposition => 'inline' }
    end
  end

  def listall
    @articles = @current_vendor.articles.existing.active.order('name, description, price')
  end

  # tested
  def new
    @article = Article.new
    @categories = @current_vendor.categories.existing.active.positioned
    @statistic_categories = @current_vendor.statistic_categories.existing
    @taxes = @current_vendor.taxes.existing
  end

  def create
    @article = Article.new
    @article.company = @current_company
    @article.vendor = @current_vendor
    
    permitted = params.require(:article).permit :active,
        :name,
        :sku,
        :description,
        :price,
        :category_id,
        :statistic_category_id,
        :taxes_array => [],
        :images_attributes => [
          :file_data
        ],
        :quantities_attributes => [
          :id,
          :price,
          :sku,
          :prefix,
          :postfix,
          :active,
          :hidden
        ]
    
    
    
    @article.attributes = permitted
    if @article.save
      @article.quantities.update_all :vendor_id => @current_vendor, :company_id => @current_company, :category_id => @article.category_id, :statistic_category_id => @article.statistic_category_id, :article_name => @article.name
      #@article.images.update_all :company_id => @article.company_id
      redirect_to articles_path
      flash[:notice] = t('articles.create.success')
    else
      @categories = @current_vendor.categories.existing.active.positioned
      @statistic_categories = @current_vendor.statistic_categories.existing
      @taxes = @current_vendor.taxes.existing
      render :new
    end
  end

  def edit
    @categories = @current_vendor.categories.existing.active.positioned
    @statistic_categories = @current_vendor.statistic_categories.existing
    @taxes = @current_vendor.taxes.existing
    session[:return_to] = /.*?\/\/.*?(\/.*)/.match(request.referer)[1] if request.referer
    @article = get_model
    redirect_to articles_path and return unless @article
    @selected_taxes = @article.taxes.collect{ |tax| tax.id }
    @article ? render(:new) : redirect_to(articles_path)
  end

  def update
    @article = get_model
    redirect_to articles_path and return unless @article
    
    permitted = params.require(:article).permit :active,
        :name,
        :sku,
        :description,
        :price,
        :category_id,
        :statistic_category_id,
        :taxes_array => [],
        :images_attributes => [
          :file_data
        ],
        :quantities_attributes => [
          :id,
          :price,
          :sku,
          :prefix,
          :postfix,
          :active,
          :hidden
          ]
    
    if @article.update_attributes permitted
      @article.quantities.update_all :vendor_id => @current_vendor,
          :company_id => @current_company,
          :category_id => @article.category_id,
          :statistic_category_id => @article.statistic_category_id,
          :article_name => @article.name
      
      flash[:notice] = t('articles.create.success')
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
       redirect_to articles_path
      end
      
    else
      @categories = @current_vendor.categories.active.existing
      @statistic_categories = @current_vendor.statistic_categories.existing
      @taxes = @current_vendor.taxes.existing
      render :new
    end
  end

  def destroy
    @article = get_model
    redirect_to articles_path and return unless @article
    @article.hide(@current_user)
    flash[:notice] = t('articles.destroy.success')
    redirect_to articles_path
  end

  def find
    if params['articles_search_text'].strip.length > 2
      search_terms = params['articles_search_text'].split.collect { |word| "%#{ word.downcase }%" }
      conditions = search_terms.collect{ |t| "LOWER(name) LIKE '#{ t }'" }.join(' AND ')
      @found_articles = @current_vendor.articles.existing.where(conditions).limit(5).order('name ASC')
    else
      render :nothing => true
    end
  end

  def change_scope
    @article = get_model
    redirect_to articles_path and return unless @article
    @source = params[:source]
    @target = params[:target]
    if @target == 'searchresults' and @source != 'searchresults'
      @article.update_attribute @source.to_sym, false
      @articleshash = build_articleshash([@source, @target])
      #@target = nil
    elsif @target == @source
      render :nothing => true
    else
      @article.update_attribute @target.to_sym, true
      @articleshash = build_articleshash([@target, @source])
      #@source = nil
    end
    @categories = @current_vendor.categories.existing.active.positioned
  end

  def sort
    params['article'].each do |id|
      a = @current_vendor.articles.existing.find_by_id(id)
      a.position = params['article'].index(a.id.to_s) + 1
      a.save
    end
    render :nothing => true
  end

  def sort_index
    @categories = @current_vendor.categories.existing.active.positioned
  end

  private

  def build_articleshash(scopes)
    articleshash = {}
    scopes.each do |s|
      articleshash.merge! s => {}
      @current_vendor.categories.existing.each do |c|
        articleshash[s][c.id] = [] if c.articles.any?
        c.articles.existing.positioned.each do |a|
          next unless a.respond_to?(s.to_sym) and a.send(s.to_sym)
          articleshash[s][c.id] << a
        end
      end
    end
    articleshash
  end
end
