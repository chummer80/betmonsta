module UsersHelper
	# reload the wallet of users that have gone broke and have no pending bets
	def self.reload_wallets
		users_without_money = User.where(balance: 0)

		users_without_money.each do |user|
			# if user has no open bets then he is really broke. give him money.
			if user.bets.where(result: nil).empty?
				user.update_attributes({balance: 10})
			end
		end
	end


	def self.calculate_ten_day_profit(user)
		bets_in_range = user.bets.where(result: %w(W L), result_time: (Time.zone.now - 10.days)..Time.zone.now)
		profit_in_range = bets_in_range.inject(0) do |result, bet|
			if bet.result == "W" 
				money_change = BetsHelper.win_amount(bet.risk_amount, bet.odds)
			elsif bet.result == "L" 
				money_change = -bet.risk_amount
			else 
				money_change = 0
			end
			result + money_change
		end

		user.update_attributes(ten_day_profit: profit_in_range)
	end

	def self.calculate_total_profit(user)
		bets_in_range = user.bets.where(result: %w(W L))
		profit_in_range = bets_in_range.inject(0) do |result, bet|
			if bet.result == "W" 
				money_change = BetsHelper.win_amount(bet.risk_amount, bet.odds)
			elsif bet.result == "L" 
				money_change = -bet.risk_amount
			else 
				money_change = 0
			end
			result + money_change
		end

		user.update_attributes(total_profit: profit_in_range)
	end
end
