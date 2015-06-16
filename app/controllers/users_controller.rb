class UsersController < ApplicationController
	before_action :authorize, only: [:index, :dashboard, :show, :edit_password, :update_password, :confirm_delete, :destroy]
	before_action :unauthorize, only: [:new, :create]
	
	# def index
	# 	redirect_to landing_page_path
	# end

	def new
		@user = User.new
	end

	def create
		user_params = params.require(:user).permit(:username, :password, :password_confirmation)
		
		error_msg = ""

		if User.find_by(username: user_params[:username])
			error_msg = "That username is taken!"
		elsif user_params[:username].length < 4
			error_msg = "Username must be at least 4 characters long"
		elsif user_params[:username].length > 20
			error_msg = "Username must be at most 20 characters long"
		elsif user_params[:password] != user_params[:password_confirmation]
			error_msg = "Passwords didn't match"
		elsif user_params[:password].length < 6
			error_msg = "Password must be at least 6 characters long"
		else
			# set some default values for user stats
			user_params[:balance] = 10.0
			user_params[:max_balance] = 10.0
			user_params[:ten_day_profit] = 0.0
			user_params[:thirty_day_profit] = 0.0
			user_params[:total_profit] = 0.0
			user_params[:admin] = false

			user = User.create(user_params)
			if user.valid?
				log_in(user)
				redirect_to user_dashboard_path
				return
			else
				error_msg = 'Unable to register you as new user'
			end
		end
			
		if error_msg
			# retain form input for user-friendliness
			@user = User.new(user_params)	
			flash.now[:alert] = error_msg
			render 'new'
		end
	end

	def dashboard
		@user = current_user
	end

	def show
		@user = current_user
	end

	def edit_password
		@user = current_user
	end

	def update_password
		user = current_user
		
		if user.authenticate(params[:password])
			if params[:new_password] == params[:new_password_confirmation]
				if params[:new_password].length >= 6
					if user.update_attributes({
						password: params[:new_password], 
						password_confirmation: params[:new_password_confirmation]
					})
						flash[:info] = "Your password has been changed"
						redirect_to user_path
						return
					else
						error_msg = "Unable to update password"
					end
				else 
					error_msg = "Password must be at least 6 characters long"
				end
			else
				error_msg = "You must enter the same new password twice in order to change it"
			end
		else
			error_msg = "Current password entered incorrectly"
		end

		if error_msg
			flash[:alert] = error_msg
			redirect_to edit_password_path
		end
	end

	def confirm_delete
	end

	def destroy
		user = current_user

		user.bets.delete_all
		log_out
		user.destroy
		redirect_to landing_page_path
	end

	def leaderboard
		# richest current players
		# @users = User.select("username, balance").order(balance: :desc).limit(10)

		@total_leaders = User.select("username, total_profit").order(total_profit: :desc).limit(10)
		@ten_day_leaders = User.select("username, ten_day_profit").order(ten_day_profit: :desc).limit(10)
	end
end