require 'OddsSharkScraper'

class BetsController < ApplicationController
	before_action :authorize, only: [:new]

	# showing the available bets
	def new
		@sport = params[:sport]

		# It's possible for user to type in an illegal path. Handle that case here.
		if %w(nba nfl mlb).include?(@sport)
			@lines = OddsSharkScraper.get_lines(@sport)
			
			if @sport == "mlb"
				@bet_type = :moneyline
			else
				@bet_type = :spread
			end
		else
			flash[:alert] = "#{@sport} is not a valid option"
			@sport = "Error"
			@lines = []
		end
	end

	def create
		# These params are all strings because they were part of
		# an HTTP request (form submission)
		sport = params[:sport]
		lines = JSON.parse(params[:lines])
		boxes = params[:boxes]
		bet_amount = params[:bet_amount].to_f

		if boxes
			if bet_amount > 0
				boxes.each do |match_index, match_boxes|
					line = lines[match_index.to_i]

					# keys are either 'home' or 'away' to indicate which side was picked
					match_boxes.each_key do |home_away| 
						bet_params = {
							match_time: line["timestamp"],
							sport: sport,
							home_team: line["teams"]["home"],
							away_team: line["teams"]["away"],
							home_picked: home_away == "home",
							spread: line["spread"][home_away],
							odds: line["odds"][home_away],
							risk_amount: bet_amount
						}

						new_bet = Bet.new(bet_params)
						if new_bet.valid?
							current_user.bets.push(new_bet)
							flash[:info] = "Your bets have been placed!"
						else
							error_msg = "Some of your bets could not be placed"
						end
					end
				end
			else
				error_msg = "You must wager some money"
			end
		else
			error_msg = "You must select at least one bet"
		end

		if error_msg
			flash[:alert] = error_msg
		end

		# go back to place bets page in case more bets are desired
		redirect_to new_bets_path(sport)
	end

	def show_pending
		@bets = current_user.bets.where(result: nil).order(match_time: :asc)
	end

	def show_history
		@bets = current_user.bets.where(result: ["W", "L"]).order(match_time: :asc)
	end
end
