class SessionsController < ApplicationController
	before_action :unauthorize, only: [:new]
	
	def new
		@user = User.new
	end

	def create
		user_params = params.require(:user).permit(:username, :password)
		user = User.where(username: user_params[:username]).first

		if user && user.authenticate(user_params[:password])
			log_in user
			flash[:success] = "Log in successful"
			redirect_to user_dashboard_path
	    else
	    	@user = User.new(user_params)
			flash.now[:alert] = "Incorrect username or password"
			render 'new'
	    end
	end

	def destroy
		log_out if current_user
		flash[:success] = "You have been logged out"
		redirect_to landing_page_path
	end
end
