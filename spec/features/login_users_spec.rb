require 'rails_helper'

RSpec.describe "Login", :type => :feature do
  describe "loggin a user in" do
    it "logs in a user and redirects to dashboard path" do
      FactoryGirl.create(:valid_user)
      visit new_session_path
      fill_in "Username", with: "Test_User"
      fill_in "Password", with: "password"
      click_on "Submit"

      expect(current_path).to eq(user_dashboard_path)
    end

    it "logs in user and shows user dropdown link menu" do
      FactoryGirl.create(:valid_user)
      visit new_session_path
      fill_in "Username", with: "Test_User"
      fill_in "Password", with: "password"
      click_on "Submit"

      expect(page).to have_css("div#user-dropdown-group")

      dropdown = page.find("div#user-dropdown-group")

      expect(dropdown).to have_css("div#user-dropdown-link", text: "Logged in as Test_User")
      expect(dropdown).to have_link("User Settings")
      expect(dropdown).to have_link("Log Out")
    end


    it "does not log in a user in with wrong password" do
      FactoryGirl.create(:valid_user)
      visit new_session_path
      fill_in "Username", with: "Test_User"
      fill_in "Password", with: "wrongpass"
      click_on "Submit"

      expect(current_path).to eq(new_session_path)
      expect(page).to have_no_css("div#user-dropdown-group", text: "Logged in as Test_User")
    end
  end
end