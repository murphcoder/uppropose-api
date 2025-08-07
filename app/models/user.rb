class User < ApplicationRecord
  has_secure_password
  has_many :proposals

  def self.from_oauth(oauth_data)
    user = where(provider: oauth_data['provider'], uid: oauth_data['id']).first_or_initialize
    user.email = oauth_data['email']
    user.first_name = oauth_data['given_name']
    user.last_name = oauth_data['family_name']
    user.password = SecureRandom.hex(10) if user.new_record?  # Set a random password if needed (or use OAuth token)
    user.save!
    user
  end

  def proposals_this_month
    proposals.where(['created_at >= ? AND created_at <= ?', Date.today.beginning_of_month, Date.today.end_of_month])
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def paid?
    date_paid.present? && date_paid >= (Date.today - 1.month)
  end

  def free_trial?
    proposals_this_month.count < 5
  end
end
