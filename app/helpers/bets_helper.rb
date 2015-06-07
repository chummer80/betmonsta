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

			# no point checking for matching bets if 1 of the lists is empty
			next if (scores.empty? || open_bets.empty?) 
				
			scores.each do |score|
				score_month = score[:timestamp].strftime('%B')
				score_day = score[:timestamp].strftime('%d')
				score_home_team = score[:teams][:home]

				matching_bets = open_bets.where(
					home_team: score_home_team, 
					match_time: (Time.now.midnight - 1.day)..Time.now.midnight
				)

				matching_bets.each do |bet|
					home_team_won = score[:final_scores][:home] > score[:final_scores][:away]
					
					bet_attributes = {}
					# if these are both true or both false, the bet won
					if home_team_won == bet.home_picked
						bet_attributes[:result] = "W"

						user_attributes = {}
						user_attributes[:balance] = user.balance + win_amount(bet.risk_amount, bet.odds)
						user_attributes[:max_balance] = [user.max_balance, user.balance].max
						user.update_attributes(user_attributes)
					else
						bet_attributes[:result] = "L"
					end

					bet_attributes[:result_time] = Time.zone.now
					bet_attributes[:resulting_balance] = user.balance

					bet.update_attributes(bet_attributes)
				end
			end
		end
	end
end
