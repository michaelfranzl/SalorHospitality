class MenucardController < ApplicationController

  def index
    @categories = Category.all
  end

  def update
    Article.update_all :menucard => 0
    params[:menucard].each do |article_id|
      Article.find(article_id).update_attribute :menucard, true
    end
    redirect_to orders_path
  end

end
