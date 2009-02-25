class ArticlesController < ApplicationController

  def index
    @categories = Category.find(:all, :order => 'name ASC')
  end

  def new
    @article = Article.new
    @groups = Group.find(:all, :order => 'name ASC')
  end

  def create
    @article = Article.new(params[:article])
    @groups = Group.find(:all, :order => 'name ASC')
    @article.save ? redirect_to(articles_path) : render(:new)
  end

  def edit
    @article = Article.find(params[:id])
    @groups = Group.find(:all, :order => 'name ASC')
    session[:return_to] = /http:\/\/.*?(\/.*)/.match(request.referer)[1]
    render :new
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes params[:article]
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        redirect_to orders_path
      end
    else
      @groups = Group.find(:all, :order => 'name ASC')
      render :new
    end
  end

  def destroy
    @article = Article.find(params[:id])
    flash[:notice] = "Der Artikel \"#{ @article.name }\" wurde erfolgreich geloescht."
    @article.destroy
    redirect_to articles_path
  end


end
