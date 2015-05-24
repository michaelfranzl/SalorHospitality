# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class PartialsController < ApplicationController

  def destroy
    partial = get_model
    partial.delete
    render :nothing => true
  end

  def create
    @presentations = @current_vendor.presentations.existing.where(:model => params[:model])
    render :no_presentation_found and return if @presentations.empty?
    
    permitted = params.require(:partial).permit :left,
      :top,
      :blurb,
      :color,
      :font,
      :size,
      :image_size,
      :width,
      :align

    @partial = Partial.new permitted
    @partial.company = @current_company
    @partial.vendor = @current_vendor
    @partial.model_id = params[:model_id]
    @partial.presentation = @presentations.first
    @partial.blurb = t('partials.default_blurb') if params[:model] == 'Presentation'
    @partial.save
    
    @page = @current_vendor.pages.existing.find_by_id params[:page_id]
    @page.partials << @partial
    @page.save
    
    @partial_html = evaluate_partial_html @partial
  end
  
  def update
    @partial = get_model
    permitted = params.require(:partial).permit :left,
      :top,
      :blurb,
      :color,
      :font,
      :size,
      :image_size,
      :width,
      :align
      
    @partial.update_attributes permitted
    @partial_html = evaluate_partial_html @partial
    @presentations = @current_vendor.presentations.existing.where(:model => @partial.presentation.model)
  end
  
  private
  
  def evaluate_partial_html(partial)
    # this goes here because binding doesn't seem to work in views
    record = partial.presentation.model.constantize.find_by_id partial.model_id
    
    begin
      eval partial.presentation.secure_expand_code
      partial_html = ERB.new( partial.presentation.secure_expand_markup).result binding
    rescue Exception => e
      partial_html = t('presentations.error_during_evaluation') + e.message
    end
    partial_html.force_encoding('UTF-8')
  end
end
