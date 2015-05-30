class UsersController < ApplicationController

	def index
		redirect_to landing_page_path
	end

	def new
		@user = User.new
	end

	def create
		user_params = params.require(:user).permit(:username, :password, :password_confirmation)
		
		existing_user = User.where(username: user_params[:username]).first
		if existing_user
			flash[:error] = "That username is taken!"
		elsif user_params[:password] != user_params[:password_confirmation]
			flash[:error] = "Passwords didn't match"
		else
			new_user = User.create(user_params)

			if new_user.valid?
				flash[:success] = 'You have been registered'
			else
				flash[:error] = 'Unable to register you as new user'
				# @user = User.new
				# render :new
			end
		end
			
		if flash[:success]
			redirect_to landing_page_path
		else
			redirect_to new_user_path
		end

	end
end