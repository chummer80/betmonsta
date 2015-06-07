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