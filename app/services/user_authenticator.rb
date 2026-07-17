require "bcrypt"

# Authenticates a user by email and password.
# Returns the User on success; raises InvalidCredentials otherwise (ADR-009).
class UserAuthenticator
  class InvalidCredentials < StandardError; end

  # Precomputed digest used to keep response time roughly constant when the
  # email does not exist, mitigating user enumeration via timing.
  DUMMY_DIGEST = BCrypt::Password.create("timing-attack-mitigation").freeze

  def self.call(email:, password:)
    new(email:, password:).call
  end

  def initialize(email:, password:)
    @email = email.to_s.strip.downcase
    @password = password.to_s
  end

  def call
    user = User.find_by(email: @email)

    unless user
      BCrypt::Password.new(DUMMY_DIGEST) == @password
      raise InvalidCredentials
    end

    raise InvalidCredentials unless user.authenticate(@password)

    user
  end
end
