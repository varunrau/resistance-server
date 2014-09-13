class User < ActiveRecord::Base
  before_save :ensure_authentication_token

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :token_authenticatable

  has_one :player

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_auth_token
    end
  end

  def to_json
    {
      name: name,
      email: email,
      win_record: win_loss_record,
      spy_record: spy_record
    }
  end

  def win_loss_record
    0#"#{(self.games_won/self.total_games).to_i}%"
  end

  def spy_record
    0#"#{(self.spy_games/self.total_games).to_i}%"
  end

  private

  def generate_auth_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
