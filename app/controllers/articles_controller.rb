# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class ArticlesController < ApplicationController

  after_filter :update_vendor_cache, :only => ['create','update','destroy', 'change_scope', 'sort']
 
  # tested
  def index
    @scopes = ['active','waiterpad']
    @articleshash = build_articleshash(@scopes)
    @categories = @current_vendor.categories.existing.active.positioned
    respond_to do |wants|
      wants.html
      wants.js { send_data @current_vendor.cache, :content_type => 'text/javascript', :disposition => 'inline' }
    end
  end

  # tested
  def active
    @categories = @current_vendor.categories.existing.active.positioned
  end

  # tested
  def waiterpad
    @categories = @current_vendor.categories.existing.active.positioned
  end

  # tested
  def listall
    @articles = @current_vendor.articles.existing.active.order('name, description, price')
  end

  # tested
  def new
    @article = Article.new
    @categories = @current_vendor.categories.existing.active.positioned
    @taxes = @current_vendor.taxes.existing
  end

  # tested
  def create
    @article = Article.new(params[:article])
    @article.company = @current_company
    @article.vendor = @current_vendor
    if @article.save
      @article.quantities.update_all :vendor_id => @current_vendor, :company_id => @current_company
      redirect_to articles_path
      flash[:notice] = t('articles.create.success')
    else
      @categories = @current_vendor.categories.existing.active.positioned
      @taxes = @current_vendor.taxes.existing
      render :new
    end
  end

  # tested
  def edit
    @categories = @current_vendor.categories.existing.active.positioned
    @taxes = @current_vendor.taxes.existing
    session[:return_to] = /.*?\/\/.*?(\/.*)/.match(request.referer)[1] if request.referer
    @article = get_model
    redirect_to roles_path and return unless @article
    @selected_taxes = @article.taxes.collect{ |tax| tax.id }
    @article ? render(:new) : redirect_to(articles_path)
  end

  # tested
  def update
    @article = get_model
    redirect_to roles_path and return unless @article
    if @article.update_attributes params[:article]
      @article.quantities.update_all :vendor_id => @current_vendor, :company_id => @current_company
      flash[:notice] = t('articles.create.success')
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
       redirect_to articles_path
      end
    else
      @categories = @current_vendor.categories.active.existing
      @taxes = @current_vendor.taxes.existing
      render :new
    end
  end

  # tested
  def destroy
    @article = get_model
    redirect_to roles_path and return unless @article
    @article.hide
    flash[:notice] = t('articles.destroy.success')
    redirect_to articles_path
  end

  # tested
  def find
    if params['articles_search_text'].strip.length > 2
      search_terms = params['articles_search_text'].split.collect { |word| "%#{ word.downcase }%" }
      conditions = search_terms.collect{ |t| "LOWER(name) LIKE '#{ t }'" }.join(' AND ')
      @found_articles = @current_vendor.articles.existing.where(conditions).limit(5).order('name ASC')
    else
      render :nothing => true
    end
  end

  # tested
  def change_scope
    @article = get_model
    redirect_to roles_path and return unless @article
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
    @categories = @current_vendor.categories.existing.active.positioned
  end

  # testing not automatable
  def sort
    params['article'].each do |id|
      a = @current_vendor.articles.existing.find_by_id(id)
      a.position = params['article'].index(a.id.to_s) + 1
      a.save
    end
    render :nothing => true
  end

  # tested
  def sort_index
    @categories = @current_vendor.categories.existing.active.positioned
  end

  private

  def build_articleshash(scopes)
    articleshash = {}
    scopes.each do |s|
      articleshash.merge! s => {}
      @current_vendor.categories.existing.active.each do |c|
        articleshash[s][c.id] = [] if c.articles.any?
        c.articles.existing.active.positioned.each do |a|
          next unless a.respond_to?(s.to_sym) and a.send(s.to_sym)
          articleshash[s][c.id] << a
        end
      end
    end
    articleshash
  end
end
