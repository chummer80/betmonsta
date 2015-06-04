module SessionsHelper

	def log_in(user)
		remember(user)
		session[:user_id] = user.id
	end

	def log_out
		forget(current_user)
		session[:user_id] = nil
		@current_user = nil
	end

	# Use cookies to keep a user logged in even if browser is closed and re-opened
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
  	user.forget
  	cookies.delete(:user_id)
   	cookies.delete(:remember_token)
  end

	def current_user
    # Try to use session to keep user logged in first
  	if (user_id = session[:user_id])
   		@current_user ||= User.find_by(id: user_id)

    # Try to use cookies as the backup (because some people disable cookies)
   	elsif (user_id = cookies.signed[:user_id])
   		user = User.find_by(id: user_id)
   		
      # Check if the user indicated by the cookies user_id is still
      # continuing the same log in session that was used to create this cookie.
      # This is done by checking if the cookies remember token is the
      # correct "password" that matches the user's current remember_digest.
      if user && user.authenticated?(cookies[:remember_token])
	     	log_in(user)
     		@current_user = user
   		end
   	end
  end

  def logged_in?
    current_user != nil
  end

  # restrict access to some pages unless there is a logged in user
  def authorize
  	unless current_user
  		flash[:alert] = "You must log in to view that page"
  		redirect_to new_session_path
  	end
  end

  # restrict access to some pages if a user is logged in
  def unauthorize
   	if current_user
     	flash[:alert] = "You must log out to view that page"
     	redirect_to user_dashboard_path
   	end
  end
end