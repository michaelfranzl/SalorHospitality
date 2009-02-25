class MenucardController < ApplicationController

  def index
    @categories = Category.all
  end

  def edit
    @menucard = {}
    Category.all.each do |category|
      articles = {}
      category.articles.each do |article|
        articles = articles.merge({ "#{article.name} | #{article.description}" => article.id })
      end
      @menucard = @menucard.merge({ category.name => articles })
    end

    @selected = []
    Article.find_all_by_menucard(true).each do |article|
      @selected << article.id
    end
  end

  def update
    Article.update_all :menucard => 0
    params[:menucard].each do |article_id|
      Article.find(article_id).update_attribute :menucard, true
    end
    redirect_to orders_path
  end

end
