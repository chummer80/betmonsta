module BetsHelper
	def line_to_s(line)
		if line >= 0
			"+" + line.to_s
		else
			line.to_s
		end
	end
end
