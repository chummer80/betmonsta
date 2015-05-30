class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  def index
  end

protected

  def current_user
  	@current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authorize
  	unless current_user
  		flash[:error] = "You must log in to view that page"
  		redirect_to new_session_path
  	end
  end

  def unauthorize
    if current_user
        flash[:error] = "You must log out to view that page"
        redirect_to user_dashboard_path
    end
  end
end
