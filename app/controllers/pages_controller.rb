class PagesController < ApplicationController
  def index
    pages = Page.existing
    if pages.empty?
      @page = Page.create
      redirect_to edit_page_path @page
    else
      redirect_to page_path(pages.first)
    end
  end
  
  def new
    @page = Page.create
    render :edit
  end
  
  def show
    @page = Page.find_by_id params[:id]
    @partial_htmls = evaluate_partial_htmls @page
    @previous_page, @next_page = neighbour_pages @page
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
      @found_articles = Article.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
      @found_options = Option.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
      @found_categories = Category.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
      @found_presentations = Presentation.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 2 )
    else
      render :nothing => true
    end
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
        eval partial.presentation.code
        partial_htmls[partial.id] = ERB.new(partial.presentation.markup).result binding
      rescue Exception => e
        partial_htmls[partial.id] = t('partials.error_during_evaluation') + e.message
      end
    end
    return partial_htmls
  end
  
  def neighbour_pages(page)
    pages = Page.existing
    idx = pages.index(page)
    previous_page = pages[idx-1]
    previous_page = page if idx.zero?
    next_page = pages[idx+1]
    next_page = page if next_page.nil?
    return previous_page, next_page
  end

end
