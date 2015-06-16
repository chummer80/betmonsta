require 'rails_helper'

RSpec.describe "Logout", :type => :feature do
	describe "log a user out" do
    	it "logs out a user and redirects to landing page" do
    		FactoryGirl.create(:valid_user)
    		visit new_session_path
    		fill_in "Username", with: "Test_User"
			fill_in "Password", with: "password"
			click_on "Submit"
			click_on "Log Out"

			expect(current_path).to eq(landing_page_path)
    	end
	end
end