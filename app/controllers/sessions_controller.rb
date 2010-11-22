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
      render 'orders/login_successful'
    else
      flash[:notice] = 'ERROR'
      render 'orders/login_wrong'
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

end
