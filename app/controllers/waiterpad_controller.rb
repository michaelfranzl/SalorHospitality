class WaiterpadController < ApplicationController

  def index
    @categories = Category.all
  end

  def edit
    @waiterpad = {}
    Category.all.each do |category|
      articles = {}
      category.articles_in_menucard.each do |article|
        articles = articles.merge({ "#{article.name} | #{article.description}" => article.id })
      end
      @waiterpad = @waiterpad.merge({ category.name => articles })
    end

    @selected = []
    Article.find_all_by_waiterpad(true).each do |article|
      @selected << article.id
    end
  end

  def update
    Article.update_all :waiterpad => 0
    params[:waiterpad].each do |article_id|
      Article.find(article_id).update_attribute :waiterpad, true
    end
    redirect_to orders_path
  end

end
