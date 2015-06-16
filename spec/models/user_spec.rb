require 'rails_helper'

RSpec.describe User, :type => :model do
	

	context "username" do
		
		it "must be present" do
			user = FactoryGirl.build(:valid_user, username: nil)
			expect(user.save).to be false
		end
		
		it "must not be blank" do
			user = FactoryGirl.build(:valid_user, username: "")
			expect(user.save).to be false
		end

		it "must be unique, disregarding capitalization" do
			user = FactoryGirl.build(:valid_user)
			expect(user.save).to be true
			
			user = FactoryGirl.build(:valid_user, username: user.username.upcase)
			expect(user.save).to be false
		end

		it "must be at least 4 characters long" do
			user = FactoryGirl.build(:valid_user, username: "123")
			expect(user.save).to be false

			user = FactoryGirl.build(:valid_user, username: "1234")
			expect(user.save).to be true
		end

		it "must be at most 20 characters long" do
			user = FactoryGirl.build(:valid_user, username: "123456789012345678901")
			expect(user.save).to be false

			user = FactoryGirl.build(:valid_user, username: "12345678901234567890")
			expect(user.save).to be true
		end

		it "must not contain white space" do
			user = FactoryGirl.build(:valid_user, username: "Test User")
			expect(user.save).to be false

			user = FactoryGirl.build(:valid_user, username: "Test	User")
			expect(user.save).to be false
		end

	end

	context "password" do

		it "must be present" do
			user = FactoryGirl.build(:valid_user, password: nil)
			expect(user.save).to be false
		end

		it "must not be blank" do
			user = FactoryGirl.build(:valid_user, password: "")
			expect(user.save).to be false
		end

		it "must be at least 6 characters long" do
			user = FactoryGirl.build(:valid_user, password: "12435")
			expect(user.save).to be false
			
			user = FactoryGirl.build(:valid_user, password: "124356")
			expect(user.save).to be true
		end

		it "must match the password confirmation" do
			user = FactoryGirl.build(:valid_user, password: "123456", password_confirmation: "654321")
			expect(user.save).to be false
		end

	end

	context "balance" do

		it "must be present" do
			user = FactoryGirl.build(:valid_user, balance: nil)
			expect(user.save).to be false
		end
		
		it "must not be negative" do
			user = FactoryGirl.build(:valid_user, balance: -0.01)
			expect(user.save).to be false
		end

		it "must be a number" do
			user = FactoryGirl.build(:valid_user, balance: "50.01")
			expect(user.save).to be true

			user = FactoryGirl.build(:valid_user, balance: "a520.01")
			expect(user.save).to be false
		end

	end

	context "max_balance" do

		it "must be present" do
			user = FactoryGirl.build(:valid_user, max_balance: nil)
			expect(user.save).to be false
		end

		it "must not be negative" do
			user = FactoryGirl.build(:valid_user, max_balance: -0.01)
			expect(user.save).to be false
		end

		it "must be a number" do
			user = FactoryGirl.build(:valid_user, max_balance: "50.01")
			expect(user.save).to be true

			user = FactoryGirl.build(:valid_user, max_balance: "a520.01")
			expect(user.save).to be false
		end

	end

	context "total_profit" do

		it "must be present" do
			user = FactoryGirl.build(:valid_user, total_profit: nil)
			expect(user.save).to be false
		end

		it "must be a number" do
			user = FactoryGirl.build(:valid_user, total_profit: "50.01")
			expect(user.save).to be true

			user = FactoryGirl.build(:valid_user, total_profit: "a520.01")
			expect(user.save).to be false
		end

	end

	context "ten_day_profit" do

		it "must be present" do
			user = FactoryGirl.build(:valid_user, ten_day_profit: nil)
			expect(user.save).to be false
		end

		it "must be a number" do
			user = FactoryGirl.build(:valid_user, ten_day_profit: "50.01")
			expect(user.save).to be true

			user = FactoryGirl.build(:valid_user, ten_day_profit: "a520.01")
			expect(user.save).to be false
		end

	end

	context "thirty_day_profit" do

		it "must be present" do
			user = FactoryGirl.build(:valid_user, thirty_day_profit: nil)
			expect(user.save).to be false
		end

		it "must be a number" do
			user = FactoryGirl.build(:valid_user, thirty_day_profit: "50.01")
			expect(user.save).to be true

			user = FactoryGirl.build(:valid_user, thirty_day_profit: "a520.01")
		end

	end

	context "remember token and digest" do

		it "should not have remember token/digest by default" do
			user = FactoryGirl.build(:valid_user)
			
			expect(user.remember_token).to be_nil
			expect(user.remember_digest).to be_nil
			expect(user.authenticated?(user.remember_token)).to be false
		end

		it "should remember user" do
			user = FactoryGirl.build(:valid_user)
			user.remember

			expect(user.remember_token).to be
			expect(user.remember_digest).to be
			expect(user.authenticated?(user.remember_token)).to be true
		end

		it "should forget user" do
			user = FactoryGirl.build(:valid_user)
			user.remember
			user.forget

			expect(user.remember_digest).to be_nil
			expect(user.authenticated?(user.remember_token)).to be false
		end

	end

end
