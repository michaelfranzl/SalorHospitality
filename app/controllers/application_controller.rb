# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :fetch_logged_in_user

  protected

    def fetch_logged_in_user
      return unless session[:user_id]
      @current_user = User.find session[:user_id]
    end

    def logged_in?
      ! @current_user.nil?
    end

    helper_method :logged_in?

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
