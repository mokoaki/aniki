class User < ActiveRecord::Base
  validates :login_id, presence: true,
                       length: { maximum: 32 },
                       uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 6 }

  has_secure_password

  before_save do
    self.login_id = login_id.downcase
  end

  before_create :create_remember_token

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
end
