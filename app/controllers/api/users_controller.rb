class Api::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      token = encode_jwt_token(user)  # After saving the user, generate the JWT token
      render json: { token: token, user: user }, status: :created
    else
      render json: { error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def profile
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
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
  