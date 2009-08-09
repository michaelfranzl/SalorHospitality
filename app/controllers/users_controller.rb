class UsersController < ApplicationController

  def index
    @users = User.find(:all, :order => :role)
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    @user.save ? redirect_to(users_path) : render(:new)
  end

  def edit
    @user = User.find(params[:id])
    render :new
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user]) ? redirect_to(users_path) : render(:new)
  end

  def destroy
    @user = User.find(params[:id])
    flash[:notice] = "Der User \"#{ @user.login }\" wurde erfolgreich geloescht."
    @user.destroy
    redirect_to users_path
  end

end
