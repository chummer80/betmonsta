module UsersHelper
	# reload the wallet of users that have gone broke and have no pending bets
	def self.reload_wallets
		reload_count = 0
		users_without_money = User.where("balance < ?", 0.01)

		users_without_money.each do |user|
			# if user has no open bets then he is really broke. give him money.
			if user.bets.where(result: nil).empty?
				user.update_attributes({balance: 10})
				reload_count += 1
			end
		end

		return "Reloaded Wallets: #{reload_count}"
	end


	def self.calculate_profit(user, range_name)
		case range_name
		when "total_profit"
			range = nil
		when "ten_day_profit"
			range = (Time.zone.now - 10.days)..Time.zone.now
		when "thirty_day_profit"
			range = (Time.zone.now - 30.days)..Time.zone.now
		end

		query = {result: %w(W L)}
		query[:result_time] = range unless range == nil

		bets_in_range = user.bets.where(query)
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

		attributes = {}
		attributes[range_name.to_sym] = profit_in_range
		user.update_attributes(attributes)
	end

end
