class SessionsController < ApplicationController
	before_action :unauthorize, only: [:new]
	
	def new
		@user = User.new
	end

	def create
		user_params = params.require(:user).permit(:username, :password)
		user = User.where(username: user_params[:username]).first

		if user && user.authenticate(user_params[:password])
	      session[:user_id] = user.id
	      flash[:success] = "Log in successful"
	      redirect_to user_dashboard_path
	    else
	      flash[:alert] = "Incorrect username or password"
	      redirect_to new_session_path
	    end
	end

	def destroy
		session[:user_id] = nil
		flash[:success] = "You have been logged out"
		redirect_to landing_page_path
	end
end
