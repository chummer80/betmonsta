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

		url = "#{@@base_url}/#{league}/scoreboard" 
		html = Nokogiri::HTML(open(url))


		scores = []

		scores_date_string = html.css('.today').text.strip
		scores_date = Time.zone.parse(scores_date_string)
		scores_nodelist = html.css('.game.link')


		scores_nodelist.each do |score_node|
			score = {}
			
			if is_final_score?(league, score_node)
				score[:timestamp] = scores_date

				score[:teams] = get_teams(league, score_node)
				score[:final_scores] = get_final_scores(league, score_node)
				scores << score
			end
		end

		scores
	end



private

	# Extract text from text-node children of this node and return it in an array
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
	

	######## Get teams #######

	def self.get_teams_mlb(score_node)
		teams = {}
		teams_nodelist = score_node.css('.team')

		home_team_node = teams_nodelist.css('.home').first
		teams[:home] = home_team_node.css('th').first.text
		
		away_team_node = teams_nodelist.css('.away').first
		teams[:away] = away_team_node.css('th').first.text

		teams
	end

	def self.get_teams_nba(score_node)
		teams = {
			home: score_node.css('> .home .team em').first.text,
			away: score_node.css('> .away .team em').first.text
		}

		teams
	end

	def self.get_teams_nfl(score_node)
	end

	def self.get_teams(league, score_node)
		case league
		when "mlb"
			get_teams_mlb(score_node)
		when "nba"			
			get_teams_nba(score_node)
		when "nfl"			
			get_teams_nfl(score_node)
		end
	end


	######## Get scores #######


	def self.get_final_scores_mlb(score_node)
		scores = {}
		teams_nodelist = score_node.css('.team')

		home_team_node = teams_nodelist.css('.home').first
		scores[:home] = home_team_node.css('.score').first.text
		
		away_team_node = teams_nodelist.css('.away').first
		scores[:away] = away_team_node.css('.score').first.text

		scores
	end

	def self.get_final_scores_nba(score_node)
		scores = {
			home: score_node.css('.score .home').first.text,
			away: score_node.css('.score .away').first.text
		}

		scores
	end

	def self.get_final_scores_nfl(score_node)
	end

	def self.get_final_scores(league, score_node)
		case league
		when "mlb"
			get_final_scores_mlb(score_node)
		when "nba"			
			get_final_scores_nba(score_node)
		when "nfl"
			get_final_scores_nfl(score_node)
		end
	end


	######## Get status of a game (is it finished yet?) #######


	def self.is_final_score?(league, score_node)
		case league
		when "mlb"
			game_status_node = score_node.css('.links .meta a').first
		when "nba"
			game_status_node = score_node.css('.details span').first
		when "nfl"
			game_status_node = nil
		end
		
		return unless game_status_node
		text_array = get_text(game_status_node)

		text_array.grep(/Final/).size > 0
	end

	def self.get_date_time(match_node)
		time_node = match_node.css('.header-time').children.first
		time = time_node.text.strip + " EST"

		DateTime.strptime(time, '%B %d %I:%M %p %Z')
	end

end