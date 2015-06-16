require 'rails_helper'

RSpec.describe 'Signup', :type => :feature do
	describe 'Signing up a new user' do
		it "creates a new user if valid info is submitted" do
			visit new_user_path
			fill_in "Username", with: "Test_User"
			fill_in "Password", with: "password"
			fill_in "Confirm", with: "password"
			click_on "Submit"

			expect(User.find_by(username: "Test_User")).to be_truthy
		end

		it "redirects to user dashboard after successful signup" do
			visit new_user_path
			fill_in "Username", with: "Test_User"
			fill_in "Password", with: "password"
			fill_in "Confirm", with: "password"
			click_on "Submit"

			expect(current_path).to eq(user_dashboard_path)
		end

		it "stays on sign up page if invalid info is submitted" do
			visit new_user_path
			fill_in "Username", with: "123"
			fill_in "Password", with: "password"
			fill_in "Confirm", with: "password"
			click_on "Submit"

			expect(current_path).to eq(new_user_path)
		end

		it "doesn't create new user if submitted username is less than 4 characters long" do
			visit new_user_path
			fill_in "Username", with: "123"
			fill_in "Password", with: "password"
			fill_in "Confirm", with: "password"
			click_on "Submit"

			expect(User.find_by(username: "123")).to be_nil

			visit new_user_path
			fill_in "Username", with: "1234"
			fill_in "Password", with: "password"
			fill_in "Confirm", with: "password"
			click_on "Submit"

			expect(User.find_by(username: "1234")).to be_truthy
		end

		it "doesn't create new user if submitted username is more than 20 characters long" do
			visit new_user_path
			fill_in "Username", with: "123456789012345678901"
			fill_in "Password", with: "password"
			fill_in "Confirm", with: "password"
			click_on "Submit"

			expect(User.find_by(username: "123456789012345678901")).to be_nil

			visit new_user_path
			fill_in "Username", with: "12345678901234567890"
			fill_in "Password", with: "password"
			fill_in "Confirm", with: "password"
			click_on "Submit"

			expect(User.find_by(username: "12345678901234567890")).to be_truthy
		end

		it "doesn't create new user if submitted password is less than 6 characters long" do
			visit new_user_path
			fill_in "Username", with: "Test_User"
			fill_in "Password", with: "12345"
			fill_in "Confirm", with: "12345"
			click_on "Submit"

			expect(User.find_by(username: "Test_User")).to be_nil

			visit new_user_path
			fill_in "Username", with: "Test_User"
			fill_in "Password", with: "123456"
			fill_in "Confirm", with: "123456"
			click_on "Submit"

			expect(User.find_by(username: "Test_User")).to be_truthy
		end

		it "doesn't create new user if submitted username is already in the database" do
			FactoryGirl.create(:valid_user)
			visit new_user_path
			fill_in "Username", with: "Test_User"
			fill_in "Password", with: "password"
			fill_in "Confirm", with: "password"
			click_on "Submit"

			expect(User.where(username: "Test_User").length).to eq(1)
		end

		it "doesn't create new user if submitted password and password confirmation don't match" do
			visit new_user_path
			fill_in "Username", with: "Test_User"
			fill_in "Password", with: "password"
			fill_in "Confirm", with: "password1"
			click_on "Submit"

			expect(User.find_by(username: "Test_User")).to be_nil
		end
	end
end