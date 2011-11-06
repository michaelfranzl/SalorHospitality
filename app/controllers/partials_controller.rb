class PartialsController < ApplicationController
  def destroy
    #article = Article.find(/([0-9]*)$/.match(params[:id])[1])
    #partial = Partial.find_by_article_id])
  end

  def create
    @presentations = Presentation.existing.find_all_by_model params[:model]
    render :no_presentation_found and return if @presentations.empty?
    @partial = Partial.new params[:partial]
    @partial.model_id = params[:model_id]
    @partial.presentation = @presentations.first
    @partial.blurb = t('partials.default_blurb') if params[:model] == 'Presentation'
    @partial.save
    
    @page = Page.find_by_id params[:page_id]
    @page.partials << @partial
    @page.save
    
    @partial_html = evaluate_partial_html @partial
  end
  
  def update
    @partial = Partial.find_by_id params[:id]
    @partial.update_attributes params[:partial]
    
    @partial_html = evaluate_partial_html @partial
    
    @presentations = Presentation.existing.find_all_by_model @partial.presentation.model
  end
  
  private
  
  def evaluate_partial_html(partial)
    # this goes here because binding doesn't seem to work in views
    record = partial.presentation.model.constantize.find_by_id partial.model_id
    
    begin
      eval partial.presentation.code
      partial_html = ERB.new( partial.presentation.markup).result binding
    rescue Exception => e
      partial_html = t('presentations.error_during_evaluation') + e.message
    end
  end

end
