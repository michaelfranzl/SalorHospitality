class BlackboardController < ApplicationController
  def index
    respond_to do |wants|
      wants.html do
        @menucard = {}
        1.upto(3) do |category_id|
          articles = {}
          category = Category.find(category_id)
          category.articles_in_menucard.each do |article|
            articles = articles.merge({ article.name => article.id })
          end
          @menucard = @menucard.merge({ category.name => articles })
        end

        @selected = []
        Article.find_all_by_blackboard(true).each do |article|
          @selected << article.id
        end

        @special = MyGlobals::blackboard_messages[:special]
        @title   = MyGlobals::blackboard_messages[:title]
        @date    = MyGlobals::blackboard_messages[:date]
      end
      wants.xml
    end
  end

  def update
    Article.update_all :blackboard => 0
    params[:blackboard].each do |article_id|
      Article.find(article_id).update_attribute :blackboard, true
    end

    MyGlobals::blackboard_messages[:special] = params[:special]
    MyGlobals::blackboard_messages[:title] = params[:title]
    MyGlobals::blackboard_messages[:date] = params[:date]

    redirect_to :controller => 'blackboard'
  end

end
