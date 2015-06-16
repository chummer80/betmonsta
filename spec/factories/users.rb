FactoryGirl.define do
	factory :valid_user, class: User do
		username "Test_User"
		password "password"
		balance 0.0
		max_balance 0.0
		total_profit 0.0
		ten_day_profit 0.0
		thirty_day_profit 0.0
	end
end
