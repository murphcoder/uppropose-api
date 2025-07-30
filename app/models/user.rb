class User < ApplicationRecord
  has_secure_password
  
  validates :first_name, presence: true
  validates :last_name, presence: true

  def self.from_oauth(oauth_data)
    user = where(provider: oauth_data['provider'], uid: oauth_data['id']).first_or_initialize
    user.email = oauth_data['email']
    user.first_name = oauth_data['given_name']
    user.last_name = oauth_data['family_name']
    user.password = SecureRandom.hex(10) if user.new_record?  # Set a random password if needed (or use OAuth token)
    user.save!
    user
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
