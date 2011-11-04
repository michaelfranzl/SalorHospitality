class PartialsController < ApplicationController
  def destroy
    #article = Article.find(/([0-9]*)$/.match(params[:id])[1])
    #partial = Partial.find_by_article_id])
  end

  def create
    @presentations = Presentation.existing.find_all_by_model params[:model]
    render :nothing => true and return if @presentations.empty?
    debugger
    # the following 3 class variables are needed for rendering _partial partial
    @model_id = params[:model_id]
    @partial = Partial.new params[:partial]
    @partial.presentation = Presentation.existing.find_by_model params[:model]

    @partial.model_id = @model_id
    @partial.save
    
    @page = Page.find_by_id(params[:page_id])
    @page.partials << @partial
    @page.save
    
    # for rendering _partial
    eval @partial.presentation.code
    @partial_html = ERB.new(@partial.presentation.markup).result binding
  end
  
  def change_presentation
    @partial = Partial.find_by_id params[:id]
    @presentation = Presentation.find_by_id params[:presentation_id]
    @partial.presentation = @presentation
    @partial.save
    @model_id = params[:model_id]
    eval @partial.presentation.code
    @partial_html = ERB.new(@partial.presentation.markup).result binding
    @presentations = Presentation.existing.find_all_by_model @partial.presentation.model
  end

end
