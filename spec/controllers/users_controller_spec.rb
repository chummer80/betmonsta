require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
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
		it "should create new user in database with given username and password" do
			post :create, {user: 
				{
					username: "asdf",
					password: "asdfasdf",
					password_confirmation: "asdfasdf"
				}
			}
			user = User.find_by(username: "asdf")
			expect(user).to be
			expect(user.authenticate("asdfasdf1")).to be false
			expect(user.authenticate("asdfasdf")).to be_truthy
		end

		it "should give new user default values for balance, max_balance, total_profit, ten_day_profit, and thirty_day_profit" do
			post :create, {user: 
				{
					username: "asdf",
					password: "asdfasdf",
					password_confirmation: "asdfasdf"
				}
			}
			user = User.find_by(username: "asdf")
			expect(user.balance).to eq(10)
			expect(user.max_balance).to eq(10)
			expect(user.total_profit).to eq(0)
			expect(user.ten_day_profit).to eq(0)
			expect(user.thirty_day_profit).to eq(0)
		end

		it "should redirect to dashboard page after valid user creation" do
			post :create, {user: 
				{
					username: "asdf",
					password: "asdfasdf",
					password_confirmation: "asdfasdf"
				}
			}
			expect(response).to redirect_to(user_dashboard_path)
		end

		it "should not create a new user if username is taken" do
			FactoryGirl.build(:valid_user).save
			post :create, {user: 
				{
					username: "Test_User",
					password: "asdfasdf",
					password_confirmation: "asdfasdf"
				}
			}
			expect(response).to render_template(:new)
			expect(flash[:alert]).to eq("That username is taken!")
			expect(User.where(username: "Test_User").length).to eq(1)
		end

		it "should not create a new user unless username is at least 4 characters long" do
			post :create, {user: 
				{
					username: "123",
					password: "asdfasdf",
					password_confirmation: "asdfasdf"
				}
			}
			expect(response).to render_template(:new)
			expect(flash[:alert]).to eq("Username must be at least 4 characters long")
			expect(User.find_by(username: "123")).to be nil

			post :create, {user: 
				{
					username: "1234",
					password: "asdfasdf",
					password_confirmation: "asdfasdf"
				}
			}
			expect(response).to redirect_to(user_dashboard_path)
			expect(User.find_by(username: "1234")).to be_truthy
		end

		it "should not create a new user unless username is at most 20 characters long" do
			post :create, {user: 
				{
					username: "123456789012345678901",
					password: "asdfasdf",
					password_confirmation: "asdfasdf"
				}
			}
			expect(response).to render_template(:new)
			expect(flash[:alert]).to eq("Username must be at most 20 characters long")
			expect(User.find_by(username: "123456789012345678901")).to be nil

			post :create, {user: 
				{
					username: "12345678901234567890",
					password: "asdfasdf",
					password_confirmation: "asdfasdf"
				}
			}
			expect(response).to redirect_to(user_dashboard_path)
			expect(User.find_by(username: "12345678901234567890")).to be_truthy
		end

		it "should not create a new user if password doesn't match password confirmation" do
			post :create, {user: 
				{
					username: "asdf",
					password: "asdfasdf",
					password_confirmation: "asdfasdf1"
				}
			}
			expect(response).to render_template(:new)
			expect(flash[:alert]).to eq("Passwords didn't match")
			expect(User.find_by(username: "asdf")).to be nil
		end

		it "should not create a new user unless password is at least 6 characters long" do
			post :create, {user: 
				{
					username: "asdf",
					password: "12345",
					password_confirmation: "12345"
				}
			}
			expect(response).to render_template(:new)
			expect(flash[:alert]).to eq("Password must be at least 6 characters long")
			expect(User.find_by(username: "asdf")).to be nil

			post :create, {user: 
				{
					username: "asdf",
					password: "123456",
					password_confirmation: "123456"
				}
			}
			expect(response).to redirect_to(user_dashboard_path)
			expect(User.find_by(username: "asdf")).to be_truthy
		end
	end
end
