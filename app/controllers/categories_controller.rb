class CategoriesController < ApplicationController
  def index
    @categories = Category.find(:all, :order => :sort_order)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])
    @category.save ? redirect_to(categories_path) : render(:new)
  end

  def edit
    @category = Category.find(params[:id])
    render :new
  end

  def update
    @category = Category.find(params[:id])
    @category.update_attributes(params[:category]) ? redirect_to(categories_path) : render(:new)
  end

  def destroy
    @category = Category.find(params[:id])
    flash[:notice] = t(:category_was_successfully_deleted, :category => @category.name)
    @category.destroy
    redirect_to categories_path
  end

end
