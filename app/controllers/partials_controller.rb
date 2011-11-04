class PartialsController < ApplicationController
  def destroy
    #article = Article.find(/([0-9]*)$/.match(params[:id])[1])
    #partial = Partial.find_by_article_id])
  end

  def update
    @page = Page.find_by_id(params[:page_id])
    @partial = Partial.create params[:partial]
    debugger
    @page.partials << @partial
    @page.save
  end

end
