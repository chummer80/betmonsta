desc "This task scrapes the Yahoo sports page for scores then resolves all open bets of all users."
task :resolve_bets => :environment do
	puts "Resolving bets..."
	BetsHelper.resolve_bets
	puts "done."
end


desc "This task gives money to broke users so they can play again."
task :reload_wallets => :environment do
	puts "Reloading wallets of broke users..."
	UsersHelper.reload_wallets
	puts "done."
end

desc "This task is a one-time total profit calculation"
task :calculate_profit => :environment do
	puts "calculating profit of all users..."
	User.all.each do |user|
		UsersHelper.calculate_profit(user, "total_profit")
		UsersHelper.calculate_profit(user, "ten_day_profit")
		UsersHelper.calculate_profit(user, "thirty_day_profit")
	end
	puts "done."
end
