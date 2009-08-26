class ArticlesController < ApplicationController

  def index
    @categories = Category.find(:all, :order => 'name ASC')
    @articles = Article.all
  end

  def new
    @article = Article.new
    @groups = Group.find(:all, :order => 'name ASC')
  end

  def new_foods
    @foods_in_menucard = Article.find(:all, :conditions => { :menucard => true, :category_id => 1..3 }).size
    starters = []
    main_dishes = []
    desserts = []
    @food_count = 6
    @food_count.times {
      starters << Article.new( :category_id => 1, :blackboard => true)
      main_dishes << Article.new( :category_id => 2, :blackboard => true)
      desserts << Article.new( :category_id => 3, :blackboard => true)
    }
    @food_categories = [ starters, main_dishes, desserts ]
  end

  def remove_all_foods_from_menucard
    Article.update_all "menucard = false, blackboard = false, waiterpad = false", :category_id => 1..3
    flash[:notice] = 'Alle Speisen wurden aus dem Menue entfernt.'
    redirect_to new_foods_articles_path
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
    logger.info "REFERER #{request.referer}"
    session[:return_to] = /.*?\/\/.*?(\/.*)/.match(request.referer)[1] if request.referer
    render :new
  end

  def update
    @categories = Category.find(:all, :order => 'name ASC')
    @article = Article.find(/([0-9]*)$/.match(params[:id])[1]) #We don't get always id's only.

    @article.update_attributes params[:article]

    respond_to do |wants|
      wants.html do #html request from new_articles_path
        if session[:return_to]
          redirect_to session[:return_to]
          session[:return_to] = nil
        else
          redirect_to orders_path
        end
      end

      wants.js do #xhr request from blackboard formatting OR drag/drop of articles
        case params[:drop_action]
        when 'add_to_menucard'
          @article.update_attribute :menucard, true
        when 'add_to_waiterpad'
          @article.update_attribute :waiterpad, true
        when 'add_to_blackboard'
          @article.update_attribute :blackboard, true
        when 'remove'
          case params[:id]
          when /drag_from_menucard.*/
            @article.update_attributes({ :menucard => false, :blackboard => false, :waiterpad => false })
          when /drag_from_waiterpad.*/
            @article.update_attribute :waiterpad, false
          when /drag_from_blackboard.*/
            @article.update_attribute :blackboard, false
          end
        end
        params[:drop_action] ? render('update_lists') : render( :nothing => true )
      end
    end
  end

  def destroy
    @article = Article.find(params[:id])
    flash[:notice] = "Der Artikel \"#{ @article.name }\" wurde erfolgreich geloescht."
    @article.destroy
    redirect_to articles_path
  end

  def find_articles
    if params['articles_search_text'].strip.length > 0
      search_terms = params['articles_search_text'].split.collect do |word|
        "%#{ word.downcase }%"
      end
      @found_articles = Article.find( :all, :conditions => [ (["(LOWER(name) LIKE ?)"] * search_terms.size).join(' AND '), * search_terms.flatten ], :order => 'name', :limit => 5 )
    end
      render :partial => 'articles_search_results'
  end

  def find_foods
    if params['foods_search_text'].strip.length > 0
      search_terms = params['foods_search_text'].split.collect do |word|
        "%#{ word.downcase }%"
      end
      @found_foods = Article.find( :all, :conditions => [ (["(LOWER(name) LIKE ?)"] * search_terms.size).join(' AND '), * search_terms.flatten ], :order => 'name', :limit => 5 )
    end
      render :partial => 'foods_search_results'
  end

end
