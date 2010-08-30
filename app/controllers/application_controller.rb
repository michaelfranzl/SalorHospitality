# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :fetch_logged_in_user
  
  protected

    def fetch_logged_in_user
      redirect_to new_session_path and return unless session[:user_id]
      @current_user = User.find session[:user_id]
    end

    def logged_in?
      ! @current_user.nil?
    end

    def ipod?
      not request.user_agent[13..16] == 'iPod'
    end

    helper_method :logged_in?, :ipod?

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
