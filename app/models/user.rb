class User < ActiveRecord::Base
  validates :login_id, presence: true,
                       length: { in: (4..64) },
                       uniqueness: { case_sensitive: false }

  validates :password, presence: true,
                       length: { minimum: 6 }

  has_secure_password

  before_save do
    self.login_id = login_id.downcase
  end

  before_create do
    self.remember_token = User.encrypt(User.new_remember_token)
  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA2.hexdigest(token.to_s)
  end
end
