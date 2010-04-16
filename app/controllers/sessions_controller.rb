class SessionsController < ApplicationController

skip_before_filter :fetch_logged_in_user

  def new
    redirect_to orders_path if session[:user_id]
  end

  def create
    @current_user = User.find_by_login_and_password params[:login], params[:password]

    if @current_user
      session[:user_id] = @current_user.id
      redirect_to orders_path
    else
      flash[:error] = 'User nicht gefunden.'
      render :action => 'new'
    end
  end

  def destroy
    session[:user_id] = @current_user = nil
    flash[:notice] = 'Logout erfolgreich.'
    redirect_to new_session_path
  end

  def set_language
    I18n.locale = session[:language] = params[:id]
    redirect_to orders_path
  end
  
  def toggle_admin_interface
    if session[:admin_interface]
      session[:admin_interface] = !session[:admin_interface]
    else
      session[:admin_interface] = true
    end
    render :nothing => true
  end

end
