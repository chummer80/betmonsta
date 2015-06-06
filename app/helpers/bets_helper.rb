require 'YahooSportsScraper'

module BetsHelper
	def line_to_s(line)
		if line >= 0
			"+" + line.to_s
		else
			line.to_s
		end
	end

	def win_amount(risk_amount, odds)
		if odds >= 100
			multiplier = odds / 100.0
		else
			multiplier = 100.0 / odds.abs
		end

		risk_amount * multiplier
	end

	def resolve_bets(user)
		# %w(nba nfl mlb).each do |sport|
		# nfl isn't tested, so remove it temporarily
		%w(nba mlb).each do |sport|
			scores = YahooSportsScraper.get_scores(sport)
			open_bets = user.bets.where(result: nil, sport: sport).order(match_time: :asc)

			if !scores.empty? && !open_bets.empty?
				open_bets.each do |bet|
					match_time = bet.match_time
					home_team = bet.home_team

					# find the entry in the scores list that corresponds
					# to the sports match that was bet on
					scores.each do |score|
						score_month = score[:timestamp].strftime('%B')
						bet_month = bet.match_time.strftime('%B')

						score_day = score[:timestamp].strftime('%d')
						bet_day = bet.match_time.strftime('%d')

						if score_month == bet_month && 
							score_day == bet_day &&
							score[:teams][:home] == bet.home_team

							home_team_won = score[:final_scores][:home] > score[:final_scores][:away]
							
							bet_attributes = {}
							# if these are both true or both false, the bet won
							if home_team_won == bet.home_picked
								bet_attributes[:result] = "W"

								user_attributes = {}
								user_attributes[:balance] = user.balance + win_amount(bet.risk_amount, bet.odds)
								user_attributes[:max_balance] = [user.max_balance, user.balance].max
								user.update_attributes(user_attributes)
							end

							bet_attributes[:result_time] = Time.zone.now
							bet_attributes[:resulting_balance] = user.balance

							bet.update_attributes(bet_attributes)
						end
					end
				end
			end
		end
	end
end
