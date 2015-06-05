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
			multiplier = odds / 100
		else
			multiplier = 100 / odds.abs
		end

		risk_amount * multiplier
	end
end
