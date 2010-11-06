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

    if request.remote_ip != '127.0.0.1' and request.remote_ip[0..2] != '192' and not ipod? and (params[:email].empty? or params[:realname].empty?)
      flash[:error] = t(:please_enter_email_and_realname)
      render :action => 'new'
    elsif @current_user
      session[:user_id] = @current_user.id
      (request.user_agent[0..6] != 'Mozilla' or request.user_agent[25..28] == 'MSIE') ? redirect_to('/session/browser_warning') : redirect_to(orders_path)
      Login.create(:ip => request.remote_ip, :email => params[:email], :reverselookup => `dig -x #{ request.remote_ip } | grep 'PTR.*.$'`, :loginname => params[:login], :realname => params[:realname], :referer => request.referer)
      flash[:error] = nil
      flash[:notice] = 'Willkommen!'
    else
      flash[:error] = t(:wrong_password)
      render :action => 'new'
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
  
  def toggle_admin_interface
    if session[:admin_interface]
      session[:admin_interface] = !session[:admin_interface]
    else
      session[:admin_interface] = true
    end
    render :nothing => true
  end

end
