class Api::UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [:create]

  def create
    user = User.new(user_params)
    if user.save
      token = encode_jwt_token(user)  # After saving the user, generate the JWT token
      render json: { token: token, user: user }, status: :created
    else
      render json: { error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def show
    render json: { user: current_user }
  end

  def update
    user = current_user
    user.assign_attributes(user_params)

    if user.stripe_customer_id.nil? && 
      user.email.present? && 
      user.first_name.present? && 
      user.last_name.present?

      stripe_customer = Stripe::Customer.create({
        email: user.email,
        name: user.full_name,
      })

      user.assign_attributes(stripe_customer_id: stripe_customer.id)
    end

    user.save
    render json: { user: current_user }
  end

  private

  def encode_jwt_token(user)
    # Generate JWT payload (e.g., user ID)
    payload = { user_id: user.id }
    
    # Encode the token with a secret key (ensure to use a strong secret)
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256') # HS256 is the algorithm
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :work_experience, :first_name, :last_name)
  end
end
  