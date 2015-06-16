require 'rails_helper'

RSpec.describe SessionsController, :type => :controller do
	include SessionsHelper

	context "new" do
		it "should return new view for new method" do
			get :new
			expect(response).to render_template(:new)
		end

		it "should create new user for the form on the new view" do
			get :new
			expect(assigns(:user)).to be_a_new(User)
		end
	end

	context "create" do
		it "should log in user with correct username and password" do
			FactoryGirl.build(:valid_user).save
			post :create, {user:
				{
					username: "Test_User",
					password: "password"
				}
			}
			expect(session[:user_id]).to be
			expect(User.find(session[:user_id])).to be
			expect(response).to redirect_to(user_dashboard_path)
		end

		it "should not log in user with incorrect password" do
			FactoryGirl.build(:valid_user).save
			post :create, {user:
				{
					username: "Test_User",
					password: "passworda"
				}
			}
			expect(session[:user_id]).to be_nil
			expect(response).to render_template(:new)
		end
	end

	context "destroy" do
		it "should destroy session when logging user out" do
			FactoryGirl.build(:valid_user).save
			post :create, {user:
				{
					username: "Test_User",
					password: "password"
				}
			}
			get :destroy
			expect(session[:user_id]).to be_nil
		end

		it "should redirect to root path after logging out" do
			FactoryGirl.build(:valid_user).save
			post :create, {user:
				{
					username: "Test_User",
					password: "password"
				}
			}
			get :destroy
			expect(response).to redirect_to(landing_page_path)
		end
	end
end
