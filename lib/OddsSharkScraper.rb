require 'open-uri'
require 'nokogiri'

def valid_float?(str)
    # The double negation turns this into an actual boolean true - if you're 
    # okay with "truthy" values (like 0.0), you can remove it.
    !!Float(str) rescue false
end

class OddsSharkScraper
	@@base_url = "http://www.oddsshark.com"

	def self.get_lines(league, type = :none)
		league.downcase!

		# by default choose spreads for NBA/NFL, and moneyline for MLB
		if type == :none
			case league
			when "mlb", "nhl"
				type = :moneyline
			when "nba", "nfl"
				type = :spread
			else
				puts "invalid league #{league}"
				return false
			end
		end

		url = "#{@@base_url}/#{league}/odds" 
		html = Nokogiri::HTML(open(url))
		matches_nodelist = html.css('.odds-page-container')


		matches = []
		matches_nodelist.each do |match_node|
			match = {}
			
			# get date/time of match and see if it has started already. if so, don't include it in the list
			match_time = get_date_time(match_node)
			next if Time.zone.now >= match_time

			match[:timestamp] = match_time

			# get teams
			match[:teams] = get_teams(match_node)

			# get spread/odds. If lines could not be found, skip to next
			# loop iteration without adding this match.
			if type == :spread
				match[:odds] = {away: -110, home: -110}
				next unless match[:spread] = get_spreads(match_node)
			else
				next unless match[:odds] = get_moneylines(match_node)
				match[:spread] = {away: 0, home: 0}
			end

			matches << match
		end

		matches
	end

private
	
	

	def self.get_date_time(match_node)
		time_node = match_node.css('.header-time').children.first
		time_str = time_node.text.strip

		# OddsShark shows times in Eastern US time zone.
		# Use Rails time zones to build time object.
		# Rails automatically uses the right one between EST or EDT. Yay!
		Time.use_zone('Eastern Time (US & Canada)') do
			Time.zone.parse(time_str)
		end
	end

	def self.get_teams(match_node)
		teams_nodelist = match_node.css('.teams a').children
		{
			away: teams_nodelist[0].text.strip,
			# The node with index 1 is a <br> tag so ignore it
			home: teams_nodelist[2].text.strip 
		}
	end

	def self.get_moneylines(match_node)
		moneylines_nodelist = match_node.css('div.book-opening span.moneyline')
		
		moneyline_strings = {
			away: moneylines_nodelist[0].text.strip,
			home: moneylines_nodelist[1].text.strip
		}

		if is_i?(moneyline_strings[:away]) && is_i?(moneyline_strings[:home])
			{
				away: moneyline_strings[:away].to_i,
				home: moneyline_strings[:home].to_i
			}
		else
			false	# this indicates failure to retrieve line
		end
	end

	def self.get_spreads(match_node)
		spreads_nodelist = match_node.css('div.book-opening span.spread')

		spread_strings = {
			away: spreads_nodelist[0].text.strip,
			home: spreads_nodelist[1].text.strip
		}

		if valid_float?(spread_strings[:away]) && valid_float?(spread_strings[:home])
			{
				away: spread_strings[:away].to_f,
				home: spread_strings[:home].to_f
			}
		else
			false	# this indicates failure to retrieve line
		end
	end

	# check if a string is a number using regex
	# this is needed to send back error code if a line is unavailable
	def self.is_i? (str)
       /\A[-+]?\d+\z/ === str
    end
end