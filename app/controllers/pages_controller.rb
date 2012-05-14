# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class PagesController < ApplicationController
  
  skip_before_filter :fetch_logged_in_user, :only => [:iframe]
  
  def index
    @pages = @current_vendor.pages.existing.active
    @partial_htmls_pages = []
    @pages.each do |p|
      @partial_htmls_pages[p.id] = evaluate_partial_htmls p
    end      
    @pages_ids = @pages.collect{ |p| p.id }
    #@current_user = @current_vendor.users.existing.active.find(session[:user_id]) if session[:user_id]
    render :index, :layout => 'iframe' unless @current_user
  end

  def iframe
    @pages = params[:id] ? @current_vendor.pages.existing.find_all_by_id(params[:id]) : Page.existing.active
    @partial_htmls_pages = []
    @pages.each do |p|
      @partial_htmls_pages[p.id] = evaluate_partial_htmls p
    end      
    @pages_ids = @pages.collect{ |p| p.id }
    render :index, :layout => 'iframe'
  end
  
  def update
    @page = @current_vendor.pages.existing.find_by_id(params[:id])
    unless @page.update_attributes params[:page]
      @page.images.reload
      @partial_htmls = evaluate_partial_htmls @page
      render(:edit) and return 
    end    
    @partial_htmls = evaluate_partial_htmls @page
    redirect_to edit_page_path @page
  end
  
  def new
    @page = Page.create :vendor_id => @current_vendor.id, :company_id => @current_company.id
    render 'edit'
  end
  
  def show
    @page = get_model
    @partial_htmls = evaluate_partial_htmls @page
    @previous_page, @next_page = neighbour_pages @page
    #@current_user = @current_vendor.users.existing.active.find(session[:user_id]) if session[:user_id]
    render :show, :layout => 'iframe' unless @current_user
  end

  def edit
    @page = get_model
    @partial_htmls = evaluate_partial_htmls @page
  end
  
  def find
    if params['search_text'].strip.length > 2
      search_terms = params['search_text'].split.collect { |word| "%#{ word.downcase }%" }
      conditions = (["(LOWER(name) LIKE ?)"] * search_terms.size).join(' AND ')
      @found_articles = @current_vendor.articles.existing.active.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
      @found_options = @current_vendor.options.existing.active.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
      @found_categories = @current_vendor.categories.existing.active.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
      @found_presentations = @current_vendor.presentations.existing.active.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
    else
      render :nothing => true
    end
  end
  
  def destroy
    @page = get_model
    @page.destroy
    redirect_to pages_path
  end
  
  private
  
  def evaluate_partial_htmls(page)
    # this goes here because binding doesn't seem to work in views
    partials = page.partials
    partial_htmls = []
    partials.each do |partial|
      # the following 3 class varibles are needed for rendering the _partial partial
      record = partial.presentation.model.constantize.find_by_id partial.model_id
      begin
        eval partial.presentation.secure_expand_code
        partial_htmls[partial.id] = ERB.new(partial.presentation.secure_expand_markup).result binding
      rescue Exception => e
        partial_htmls[partial.id] = t('partials.error_during_evaluation') + e.message
      end
      partial_htmls[partial.id].force_encoding('UTF-8')
    end
    return partial_htmls
  end
  
  def neighbour_pages(page)
    pages = @current_vendor.pages.existing
    idx = pages.index(page)
    previous_page = pages[idx-1]
    previous_page = page if idx.zero?
    next_page = pages[idx+1]
    next_page = page if next_page.nil?
    return previous_page, next_page
  end

end
