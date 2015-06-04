class Bet < ActiveRecord::Base
  belongs_to :user

  validates :match_time, presence: true
  validates :sport, presence: true
  validates :home_team, presence: true
  validates :away_team, presence: true
  validates :home_picked, inclusion: { in: [true, false] } 
  validates :spread, presence: true, numericality: { only_integer: true }
  validates :odds, presence: true, numericality: { only_integer: true }
  validates :risk_amount, presence: true, numericality: {greater_than: 0}
end
