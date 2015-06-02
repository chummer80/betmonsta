require 'OddsSharkScraper'

class BetsController < ApplicationController

	def create
		@sport = params[:sport]

		@lines = OddsSharkScraper.get_lines(@sport)
		
		if @sport == "mlb"
			@bet_type = :moneyline
		else
			@bet_type = :spread
		end
	end
end
