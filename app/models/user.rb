class User < ApplicationRecord
  has_secure_password

  enum :role, { member: 0, admin: 1 }, default: :member

  before_validation :normalize_email

  validates :name, presence: true
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
