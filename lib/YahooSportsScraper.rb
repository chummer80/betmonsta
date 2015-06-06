require 'open-uri'
require 'nokogiri'

class YahooSportsScraper
	@@base_url = "http://sports.yahoo.com/"

	def self.get_scores(league)
		league.downcase!


		unless %w(nba nfl mlb).include?(league)
			puts "invalid league #{league}"
			return false
		end

		url = "#{@@base_url}/#{league}/scoreboard/?date=2015-06-04" 
		html = Nokogiri::HTML(open(url))
		

		scores = []

		scores_date_string = html.css('.today').text.strip
		scores_date = DateTime.strptime(scores_date_string, '%A, %B %d')
		scores_nodelist = html.css('.game.link')

		scores_nodelist.each do |score_node|
			score = {}
			
			if is_final_score?(score_node)
				score[:timestamp] = scores_date

				score[:teams] = get_teams(score_node)
				score[:final_scores] = get_final_scores(score_node)
			end
		end

		scores
	end



private

	def self.get_text(node)
		text_array = []
		children = node.children
		children.each do |child|
			if child.text?
				text_array << child.text.strip
			end
		end
		text_array
	end
	
	def self.get_teams(score_node)
		teams = {}
		teams_nodelist = score_node.css('.team')

		home_team_node = teams_nodelist.css('.home').first
		teams[:home] = home_team_node.css('th').first.text
		
		away_team_node = teams_nodelist.css('.away').first
		teams[:away] = away_team_node.css('th').first.text

		teams
	end

	def self.get_final_scores(score_node)
		scores = {}
		teams_nodelist = score_node.css('.team')

		home_team_node = teams_nodelist.css('.home').first
		scores[:home] = home_team_node.css('.score').first.text
		
		away_team_node = teams_nodelist.css('.away').first
		scores[:away] = away_team_node.css('.score').first.text

		scores
	end

	def self.is_final_score?(score_node)
		game_status_node = score_node.css('.links .meta a').first
		return unless game_status_node
		text_array = get_text(game_status_node)

		text_array.include?("Final")
	end

	def self.get_date_time(match_node)
		time_node = match_node.css('.header-time').children.first
		time = time_node.text.strip + " EST"

		DateTime.strptime(time, '%B %d %I:%M %p %Z')
	end

end