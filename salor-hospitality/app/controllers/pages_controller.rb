# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class PagesController < ApplicationController
  
  before_filter :check_permissions, :except => [:iframe]
  before_filter :fetch_vendor, :only => [:iframe]
  skip_before_filter :fetch_logged_in_user, :only => [:iframe]
  
  def index
    @pages = @current_vendor.pages.existing.active
    @partial_htmls_pages = []
    @pages.each do |p|
      @partial_htmls_pages[p.id] = p.evaluate_partial_htmls
    end
    @pages_ids = @pages.collect{ |p| p.id }
    #@current_user = @current_vendor.users.existing.active.find(session[:user_id]) if session[:user_id]
    render :index, :layout => 'iframe' unless @current_user
  end

  def iframe
    if defined?(ShSaas) == 'constant'
      redirect_to sh_saas.root_path and return
    end
    @pages = params[:id] ? @vendor.pages.existing.where(:id => params[:id]) : @vendor.pages.existing.active
    @partial_htmls_pages = []
    @pages.each do |p|
      @partial_htmls_pages[p.id] = p.evaluate_partial_htmls
    end      
    @pages_ids = @pages.collect{ |p| p.id }
    render :index, :layout => 'iframe'
  end
  
  def update
    @page = @current_vendor.pages.existing.find_by_id(params[:id])
    
    permitted = params.require(:page).permit :width,
      :height,
      :color,
      :images_attributes => [
        :file_data
      ]
        
    unless @page.update_attributes permitted
      @page.images.reload
      @partial_htmls = @page.evaluate_partial_htmls
      render(:edit) and return 
    end    
    @partial_htmls = @page.evaluate_partial_htmls
    redirect_to edit_page_path @page
  end
  
  def new
    @page = Page.create :vendor_id => @current_vendor.id, :company_id => @current_company.id
  end
  
  def show
    @page = get_model
    @partial_htmls = @page.evaluate_partial_htmls
    @previous_page, @next_page = neighbour_pages @page
    #@current_user = @current_vendor.users.existing.active.find(session[:user_id]) if session[:user_id]
    render :show, :layout => 'iframe' unless @current_user
  end

  def edit
    @page = get_model
    @partial_htmls = @page.evaluate_partial_htmls
  end
  
  def find
    str = params['search_text'].strip
    if str.length > 2
      
      @found_articles = @current_vendor.articles.existing.active.where("name LIKE '%#{ str}%' ").order(:name).limit(2)
      
      @found_options = @current_vendor.options.existing.active.where("name LIKE '%#{ str}%' ").order(:name).limit(2)
      
      @found_categories = @current_vendor.categories.existing.active.where("name LIKE '%#{ str}%' ").order(:name).limit(2)
      
      @found_presentations = @current_vendor.presentations.existing.active.where("name LIKE '%#{ str}%' ").order(:name).limit(2)
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
  

  
  def neighbour_pages(page)
    pages = @current_vendor.pages.existing
    idx = pages.index(page)
    previous_page = pages[idx-1]
    previous_page = page if idx.zero?
    next_page = pages[idx+1]
    next_page = page if next_page.nil?
    return previous_page, next_page
  end
  
  def fetch_vendor
    @company = Company.existing.active.first
    @vendor = @company.vendors.existing.find_by_id(params[:v])
  end

end
