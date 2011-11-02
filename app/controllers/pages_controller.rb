class PagesController < ApplicationController
  def index
    @pages = Page.all
  end
  
  def show
    @page = Page.find_by_id params[:id]
    @partials = @page.partials
    @partial_htmls = []
    @partials.each do |par|
      eval par.code
      @partial_htmls[par.id] = ERB.new(par.template).result binding
    end
    #eval Partial.first.code
    #@test = ERB.new(Partial.first.template).result binding
  end

  def edit
  end

  def update
  end

end
