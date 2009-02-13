class ArticlesController < ApplicationController

  def index
    @categories = Category.find(:all)
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(params[:article])
    @article.save ? redirect_to(articles_path) : render(:new)
  end

  def edit
    @article = Article.find(params[:id])
    render :new
  end

  def update
    @article = Article.find(params[:id])
    @article.update_attributes(params[:article]) ? redirect_to(articles_path) : render(:new)
  end

  def destroy
    @article = Article.find(params[:id])
    flash[:notice] = "Der Artikel \"#{ @article.name }\" wurde erfolgreich geloescht."
    @article.destroy
    redirect_to articles_path
  end


end
