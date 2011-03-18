class SessionsController < ApplicationController

  skip_before_filter :fetch_logged_in_user

  def new
    @users = User.all
    redirect_to orders_path if session[:user_id]
  end

  def browser_warning
  end
  
  def create
    @current_user = User.find_by_login_and_password params[:login], params[:password]
    @users = User.all
    if @current_user
      redirect_to '/'
      session[:user_id] = @current_user
      flash[:error] = nil
      flash[:notice] = nil
    else
      flash[:error] = t :wrong_password
      render :new
    end
  end

  def destroy
    session[:user_id] = @current_user = nil
    flash[:notice] = t(:logout_successful)
    redirect_to new_session_path
  end

  def set_language
    I18n.locale = session[:language] = params[:id]
    redirect_to orders_path
  end

  def catcher
    redirect_to '/'
  end

end
