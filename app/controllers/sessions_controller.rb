class SessionsController < ApplicationController
	before_action :unauthorize, only: [:new, :create]
	before_action :authorize, only: [:destroy]
	
	def new
		@user = User.new
	end

	def create
		user_params = params.require(:user).permit(:username, :password)
		user = User.find_by(username: user_params[:username])

		if user && user.authenticate(user_params[:password])
			log_in user
			redirect_to user_dashboard_path
	    else
	    	@user = User.new(user_params)
			
	    	# use render instead of redirect so user input can persist in the form
			flash.now[:alert] = "Incorrect username or password"
			render 'new'
	    end
	end

	def destroy
		log_out if logged_in?
		redirect_to landing_page_path
	end
end
