require 'OddsSharkScraper'

class BetsController < ApplicationController
	include BetsHelper
	
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
		placed_bet_count = 0

		if boxes
			if bet_amount > 0

				# Count number of checkboxes and multiply by bet_amount to get total risk.
				# Give an error if user doesn't have enough funds
				total_risk = 0
				boxes.each_value do |match_boxes|
					# each match could have either 1 checkbox checked or 2 checkboxes checked.
					# I don't know why anyone would bet on both sides of a match, but I guess it's possible.
					total_risk += match_boxes.size * bet_amount
				end

				if total_risk <= current_user.balance
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
								placed_bet_count += 1

								if placed_bet_count == 1
									flash[:info] = "#{placed_bet_count} bet has been placed!"
								else
									flash[:info] = "#{placed_bet_count} bets have been placed!"
								end
							else
								flash[:alert] = "Some of your bets could not be placed"
							end
						end
					end

					# remove funds from user account.
					# calculate total here instead of using total_risk just in case some bets couldn't be placed
					if placed_bet_count > 0
						current_user.update_attributes(balance: current_user.balance - (placed_bet_count * bet_amount))
					end
				else
					flash[:alert] = "You tried to wager #{ActionController::Base.helpers.number_to_currency(total_risk)} but you don't have enough money!"
				end
			else
				flash[:alert] = "You must wager some money"
			end
		else
			flash[:alert] = "You must select at least one bet"
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
