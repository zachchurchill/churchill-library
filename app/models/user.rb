class User < ApplicationRecord
  before_save { self.name = name.downcase }
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
  has_secure_password
  VALID_PASSWORD_REGEX = /(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}/
  validates :password, presence: true, length: { minimum: 10 }, format: { with: VALID_PASSWORD_REGEX }
end
