class PagesController < ApplicationController
  def index
    @page = Page.existing.first
    @partial_htmls = evaluate_partial_htmls @page
  end
  
  def show
    @page = Page.find_by_id params[:id]
    @partials = @page.partials
    @partial_htmls = []
    @partials.each do |par|
      eval par.code
      @partial_htmls[par.id] = ERB.new(par.template).result binding
    end
  end

  def edit
    @page = Page.find_by_id params[:id]
    @partial_htmls = evaluate_partial_htmls @page
  end
  
  def find
      if params['search_text'].strip.length > 2
      search_terms = params['search_text'].split.collect { |word| "%#{ word.downcase }%" }
      conditions = 'hidden = false AND '
      conditions += (["(LOWER(name) LIKE ?)"] * search_terms.size).join(' AND ')
      @found_articles = Article.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 3 )
      @found_options = Option.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 3 )
      @found_categories = Category.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 3 )
    else
      render :nothing => true
    end
  end
  
  private
  
  def evaluate_partial_htmls(page)
    # this goes here because binding doesn't seem to work in views
    partials = page.partials
    partial_htmls = []
    partials.each do |par|
      # the following 3 class varibles are needed for rendering the _partial partial
      partial = par
      model_id = partial.model_id
      eval partial.presentation.code
      partial_htmls[partial.id] = ERB.new(partial.presentation.markup).result binding
    end
    return partial_htmls
  end

end
