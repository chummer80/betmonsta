desc "This task scrapes the Yahoo sports page for scores then resolves all open bets of all users."
task :resolve_bets => :environment do
  puts "Resolving bets..."
  BetsHelper.resolve_bets
  puts "done."
end