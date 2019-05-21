class User < ApplicationRecord

  attr_accessor :remember_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_save { email.downcase! }

  validates :name,
    presence: true,
    length: {maximum: 50}

  validates :email,
    presence: true,
    length: {maximum: 255},
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: {case_sensitive: false}

  has_secure_password

  validates :password,
    presence: true,
    length: {minimum: 6},
    # has_secure_password prevents users from having nil passwords, this just
    # allows users to edit their info without providing a password
    allow_nil: true 

  # returns the hash digest of the given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
      BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # returns true if the given token matches the digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # forgets a user (deleting their remember token)
  def forget
    update_attribute(:remember_digest, nil)
  end
end
