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
end
