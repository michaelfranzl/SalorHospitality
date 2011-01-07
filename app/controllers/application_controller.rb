# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :fetch_logged_in_user
  helper_method :logged_in?, :ipod?, :workstation?

  private

    def local_request?
      false
    end

    def rescue_action_in_public(exception)
      redirect_to orders_path
    end

    def fetch_logged_in_user
      @current_user = User.find session[:user_id] if session[:user_id]
      render 'go_to_login' if (request.xhr? and !@current_user) #only when user is logging out on ipod, for normal request let the views handle the login form diplay
    end

    def logged_in?
      ! @current_user.nil?
    end

    def ipod?
      ((request.user_agent[13..16] == 'iPod') or (request.user_agent[13..16] == 'iPho') or params[:ipod])
    end

    def workstation?
      not ipod?
    end


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
