class ArticlesController < ApplicationController

  def index
    @categories = Category.find(:all, :order => 'sort_order')
    @scopes = ['menucard','waiterpad']
    @articles = Article.all
    respond_to do |wants|
      wants.html
      wants.js
    end
  end

  def listall
    @articles = Article.find(:all, :order => 'name, description, price', :conditions => { :hidden => false })
  end

  def new
    @article = Article.new
    @groups = Group.find(:all, :order => 'name ASC')
  end

  def create
    @article = Article.new(params[:article])
    @groups = Group.find(:all, :order => 'name ASC')
    respond_to do |wants|
      wants.html { @article.save ? redirect_to(articles_path) : render(:new) }
      wants.js do
        @id = params[:id]
        @article.save
        @foods_in_menucard = Article.find(:all, :conditions => { :menucard => true, :category_id => 1..3 }).size
      end
    end
  end

  def edit
    @article = Article.find(params[:id])
    @groups = Group.find(:all, :order => 'name ASC')
    session[:return_to] = /.*?\/\/.*?(\/.*)/.match(request.referer)[1] if request.referer
    render :new
  end

  def update
    @categories = Category.find(:all, :order => 'sort_order')

    @article.update_attributes params[:article]
    if @article.hidden
      @article.quantities.each do |q|
        q.update_attribute :hidden, true
      end
    end

    if @article.save
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        redirect_to orders_path
      end
    else
      render :new
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    File.open('public/articles.js', 'w') { |out| out.write(generate_js_database(@categories)) }
    redirect_to articles_path
  end

  def find
    if params['articles_search_text'].strip.length > 2
      search_terms = params['articles_search_text'].split.collect { |word| "%#{ word.downcase }%" }
      conditions = 'hidden = false AND '
      conditions += (["(LOWER(name) LIKE ?)"] * search_terms.size).join(' AND ')
      @found_articles = Article.find( :all, :conditions => [ conditions, *search_terms.flatten ], :order => 'name', :limit => 5 )
      render :layout => false
    else
      render :nothing => true
    end
  end

  def change_scope
    @scopes = ['menucard','waiterpad']
    @categories = Category.find(:all, :order => 'sort_order')

    @article = Article.find(/([0-9]*)$/.match(params[:id])[1])

    case params[:add_to]
    when 'menucard'
      @article.update_attribute :menucard, true
    when 'waiterpad'
      @article.update_attribute :waiterpad, true
    when 'blackboard'
      @article.update_attribute :blackboard, true
    when 'remove'
      case params[:id]
      when /menucard.*/
        @article.update_attributes({ :menucard => false, :blackboard => false, :waiterpad => false })
      when /waiterpad.*/
        @article.update_attribute :waiterpad, false
      when /blackboard.*/
        @article.update_attribute :blackboard, false
      end
    end
  end

end
