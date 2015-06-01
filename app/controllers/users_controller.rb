class UsersController < ApplicationController
	before_action :authorize, only: [:dashboard]
	before_action :unauthorize, only: [:new]
	
	def index
		redirect_to landing_page_path
	end

	def new
		@user = User.new
	end

	def create
		user_params = params.require(:user).permit(:username, :password, :password_confirmation)
		
		error_msg = ""

		if User.find_by(username: user_params[:username])
			error_msg = "That username is taken!"
		elsif user_params[:password] != user_params[:password_confirmation]
			error_msg = "Passwords didn't match"
		else
			# set some default values for user stats
			user_params[:balance] = 0.0
			user_params[:max_balance] = 0.0
			user_params[:ten_day_profit] = 0.0
			user_params[:thirty_day_profit] = 0.0
			user_params[:total_profit] = 0.0
			user_params[:admin] = false

			user = User.create(user_params)
			if user.valid?
				log_in(user)
				# flash[:success] = 'You have been registered'
			else
				error_msg = 'Unable to register you as new user'
			end
		end
			
		if error_msg.empty?
			redirect_to landing_page_path
		else
			@user = User.new(user_params)	# retain form input for user-friendliness
			flash.now[:alert] = error_msg
			render 'new'
		end
	end

	def dashboard
		@user = current_user
	end
end