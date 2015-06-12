require 'YahooSportsScraper'

module BetsHelper
	def line_to_s(line)
		if line >= 0
			"+" + line.to_s
		else
			line.to_s
		end
	end

	def self.win_amount(risk_amount, odds)
		if odds >= 100
			multiplier = odds / 100.0
		else
			multiplier = 100.0 / odds.abs
		end

		risk_amount * multiplier
	end

	def self.resolve_bets(user = nil)
		# if user is not specified, then resolve all users' bets
		resolving_all_users = !user
		resolved_bet_count = 0

		%w(nba nfl mlb nhl).each do |sport|
			if resolving_all_users
				open_bets = Bet.where(result: nil, sport: sport).order(match_time: :asc)
			else
				open_bets = user.bets.where(result: nil, sport: sport).order(match_time: :asc)
			end
			scores = YahooSportsScraper.get_scores(sport)

			# no point checking for matching bets if either one of the lists is empty
			next if (scores.empty? || open_bets.empty?) 
				
			scores.each do |score|
				score_home_team = score[:teams][:home]

				matching_bets = open_bets.where(
					home_team: score_home_team, 
					match_time: (Time.zone.now.midnight..(Time.zone.now.midnight + 23.hours + 59.minutes + 59.seconds))
				)
				matching_bets.each do |bet|
					bet_owner = resolving_all_users ? bet.user : user

					# convert scores to numbers so they can be modified and compared properly
					home_team_score = score[:final_scores][:home].to_f
					away_team_score = score[:final_scores][:away].to_f

					# add spread to the team that was bet on
					if bet.home_picked
						home_team_score += bet.spread
					else
						away_team_score += bet.spread
					end

					home_team_beat_spread = home_team_score > away_team_score
					
					bet_attributes = {}
					
					# if these are both true or both false, the bet won
					if home_team_score == away_team_score
						bet_attributes[:result] = "P"
						user_attributes = {}
						# get back risk amount in the case of a push
						user_attributes[:balance] = bet_owner.balance + bet.risk_amount
						user_attributes[:max_balance] = [bet_owner.max_balance, bet_owner.balance].max
						bet_owner.update_attributes(user_attributes)
					elsif home_team_beat_spread == bet.home_picked
						bet_attributes[:result] = "W"
						user_attributes = {}
						# get back risk amount in addition to win amount
						user_attributes[:balance] = bet_owner.balance + bet.risk_amount + BetsHelper.win_amount(bet.risk_amount, bet.odds)
						user_attributes[:max_balance] = [bet_owner.max_balance, bet_owner.balance].max
						bet_owner.update_attributes(user_attributes)
					else
						bet_attributes[:result] = "L"
					end

					bet_attributes[:result_time] = Time.zone.now
					bet_attributes[:resulting_balance] = bet_owner.balance

					bet.update_attributes(bet_attributes)

					resolved_bet_count += 1
				end
			end
		end

		puts "Done Resolving Bets: #{resolved_bet_count}"
		return
	end
end
