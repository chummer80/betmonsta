require 'OddsSharkScraper'

class BetsController < ApplicationController

	def new
		@sport = params[:sport]

		# if @sport == "nba" || @sport == "nfl" || @sport == "mlb"
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
		sport = params[:sport]
		lines = params[:lines]
		boxes = params[:boxes].values

		redirect_to new_bets_path(sport)
	end
end
