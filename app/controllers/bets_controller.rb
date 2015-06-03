require 'OddsSharkScraper'

class BetsController < ApplicationController

	def new
		@sport = params[:sport]

		@lines = OddsSharkScraper.get_lines(@sport)
		
		if @sport == "mlb"
			@bet_type = :moneyline
		else
			@bet_type = :spread
		end
	end

	def create
		sport = params[:sport]
		lines = params[:lines]
		boxes = params[:boxes].values

		redirect_to new_bets_path(sport)
	end
end
