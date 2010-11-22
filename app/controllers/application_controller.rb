# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :fetch_logged_in_user
  helper_method :logged_in?, :ipod?

  #rescue_from ActionController::RoutingError, :with => :route_not_found
  #rescue_from ActionController::MethodNotAllowed, :with => :invalid_method

  private

    def rescue_action_in_public(exception)
      redirect_to orders_path
    end

    def local_request?
      false
    end

    def fetch_logged_in_user
      @current_user = User.find session[:user_id] if session[:user_id]
      #render 'login' unless @current_user
    end

    def logged_in?
      ! @current_user.nil?
    end

    def ipod?
      ((request.user_agent[13..16] == 'iPod') or (request.user_agent[13..16] == 'iPho') or params[:ipod])
    end

    def route_not_found
      redirect_to orders_path
    end

    def invalid_method
      redirect_to orders_path
    end


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
