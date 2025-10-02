require 'stripe'

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

  def subscription_link
    monthly_price_id = Rails.env == 'development' ? 'price_1SDPicGsrou80PAeOYz8kSVl' : 'price_1Rsx1ZGsrou80PAeA2cDc3fv'  # Replace with your actual monthly price ID
    yearly_price_id = Rails.env == 'development' ? 'price_1SDPicGsrou80PAevahnimFd' : 'price_1SDLcVGsrou80PAeuo38KdOn'    # Replace with your actual yearly price ID

    monthly_checkout_session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      mode: 'subscription',
      line_items: [
        {
          price: monthly_price_id,  # You can choose to use either price here
          quantity: 1,
        }
      ],
      customer: stripe_customer_id,
      success_url: ENV['FRONTEND_URI']
    })

    yearly_checkout_session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      mode: 'subscription',
      line_items: [
        {
          price: yearly_price_id,  # You can choose to use either price here
          quantity: 1,
        }
      ],
      customer: stripe_customer_id,
      success_url: ENV['FRONTEND_URI']
    })

    [monthly_checkout_session.url, yearly_checkout_session.url]
  end

  def proposals_this_month
    proposals.where(['created_at >= ? AND created_at <= ?', Date.today.beginning_of_month, Date.today.end_of_month])
  end

  def expiration_date
    if date_paid.nil?
      nil
    else
      case subscription_length
      when 'month'
        date_paid + 1.month
      when 'year'
        date_paid + 1.year
      end
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def free_trial?
    proposals_this_month.count < 5
  end
end
