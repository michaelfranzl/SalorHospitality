class ArticlesController < ApplicationController

  def index
    @categories = Category.find(:all, :order => 'sort_order')
    respond_to do |wants|
      wants.html {
        @articles = Article.all
      }
      wants.js { render :text => generate_js_database(@categories) }
    end
  end

  def listall
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
    MyGlobals.last_js_change = Time.now.strftime('%Y%m%dT%H%M%S')
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
    MyGlobals.last_js_change = Time.now.strftime('%Y%m%dT%H%M%S')
    session[:return_to] = /.*?\/\/.*?(\/.*)/.match(request.referer)[1] if request.referer
    render :new
  end

  def update
    @categories = Category.find(:all, :order => 'name ASC')
    @article = Article.find(/([0-9]*)$/.match(params[:id])[1]) #We don't get always id's only.
    @article.update_attributes params[:article]
    MyGlobals.last_js_change = Time.now.strftime('%Y%m%dT%H%M%S')

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
    MyGlobals.last_js_change = Time.now.strftime('%Y%m%dT%H%M%S')
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



private

  class Helper
    class << self
     #include Singleton - no need to do this, class objects are singletons
     include ActionView::Helpers::JavaScriptHelper
    end
  end
  
  def generate_js_database(categories)
    articleslist = 
    "var articleslist = new Array();" +
    categories.collect{ |cat|
      "\narticleslist[#{ cat.id }] = \"" +
      cat.articles_in_menucard.collect{ |art|
        action = art.quantities.empty? ? "add_new_item_a(#{ art.id });" : "display_quantities(#{ art.id });"
        "<tr><td class='article' onclick='#{ action }' onmousedown='highlight_button(this); deselect_all_articles()' onmouseup='highlight_button(this)'>#{ Helper.escape_javascript art.name }</td></tr>"
      }.to_s + '";'
    }.to_s

    quantitylist =
    "\n\nvar quantitylist = new Array();" +
    categories.collect{ |cat|
      cat.articles_in_menucard.collect{ |art|
        next if art.quantities.empty?
        "\nquantitylist[#{ art.id }] = \"" +
        art.quantities.collect{ |qu|
          "<tr><td class='quantity' onclick='add_new_item_q(#{ qu.id })' onmousedown='highlight_button(this)' onmouseup='restore_button(this)'>#{ Helper.escape_javascript qu.name }</td></tr>"
        }.to_s + '";'
      }.to_s
    }.to_s

    itemdetails_q =
    "\n\nvar itemdetails_q = new Array();" +
    categories.collect{ |cat|
      cat.articles_in_menucard.collect{ |art|
        art.quantities.collect{ |qu|
          "\nitemdetails_q[#{ qu.id }] = new Array( '#{ qu.article.id }', '#{ Helper.escape_javascript qu.article.name }', '#{ Helper.escape_javascript qu.name }', '#{ qu.price }', '#{ Helper.escape_javascript qu.article.description }', '#{ Helper.escape_javascript compose_item_label(qu) }');"
        }.to_s
      }.to_s
    }.to_s
    

    itemdetails_a =
    "\n\nvar itemdetails_a = new Array();" +
    categories.collect{ |cat|
      cat.articles_in_menucard.collect{ |art|
        "\nitemdetails_a[#{ art.id }] = new Array( '#{ art.id }', '#{ Helper.escape_javascript art.name }', '#{ Helper.escape_javascript art.name }', '#{ art.price }', '#{ Helper.escape_javascript art.description }', '#{ Helper.escape_javascript compose_item_label(art) }');"
      }.to_s
    }.to_s
    
    return articleslist + quantitylist + itemdetails_q + itemdetails_a + "testvar = 'abc';"
  end
  
  
  def compose_item_label(input)
    if input.class == Quantity
      label = "#{ input.article.name }<br><small>#{ input.price } EUR, #{ input.name }</small>"
    else
      label = "#{ input.name }<br><small>#{ input.price } EUR</small>"
    end
    return label
  end


end
