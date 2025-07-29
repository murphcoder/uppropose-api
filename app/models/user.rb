class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :jwt_authenticatable,
         :omniauthable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null,
         omniauth_providers: [:google_oauth2]
  
  validates :first_name, presence: true
  validates :last_name, presence: true

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email
    user.password = Devise.friendly_token[0, 20] if user.new_record?
    user.save!
    user
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
