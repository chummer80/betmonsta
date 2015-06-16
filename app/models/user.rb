class User < ActiveRecord::Base
	attr_accessor :remember_token
	has_many :bets

	validates :username, 
		presence: true, 
		uniqueness: {case_sensitive: false},
		length: {minimum: 4, maximum: 20},
		format: {without: /\s/}
	# validates :password_digest, 
	# 	presence: true
	has_secure_password
	validates :password, presence: true, length: {minimum: 6}
	validates :balance, 
		presence: true, 
		numericality: {greater_than_or_equal_to: 0}
	validates :max_balance, 
		presence: true, 
		numericality: {greater_than_or_equal_to: 0}
	validates :ten_day_profit, 
		presence: true, 
		numericality: true
	validates :thirty_day_profit, 
		presence: true, 
		numericality: true
	validates :total_profit, 
		presence: true, 
		numericality: true


	# Returns the hash digest of the given string.
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

  # Use this to give user a different remember token every time they log in
	def self.new_token
		SecureRandom.urlsafe_base64
	end

	# Remembers a user in the database for use in persistent sessions.
	def remember
  		self.remember_token = User.new_token
 		update_attribute(:remember_digest, User.digest(remember_token))
	end

	# Forgets a user.
	def forget
  		update_attribute(:remember_digest, nil)
	end

	# Returns true if the given token matches the digest.
	def authenticated?(remember_token)
		return false if remember_digest.nil?
  		BCrypt::Password.new(remember_digest).is_password?(remember_token)
	end
end
