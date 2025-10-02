# app/controllers/api/users/sessions_controller.rb
class Api::Users::SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: [:create]
  
  # POST /api/users/sign_in
  def create
      user = User.find_by(email: params[:email])
      
      if user && user.authenticate(params[:password])  # Check the password using bcrypt
        token = encode_jwt_token(user)  # Generate a JWT token
        render json: { token: token, user: user, expirationDate: user.expiration_date, proposalCount: user.proposals_this_month.count }, status: :ok
      else
        render json: { error: 'Invalid credentials' }, status: :unauthorized
      end
  end

  # DELETE /api/users/sign_out
  def destroy
    # Optionally implement logout functionality here (e.g., blacklist the JWT)
    render json: { message: 'Successfully logged out' }, status: :ok
  end

  private

  def encode_jwt_token(user)
      # Generate JWT payload (e.g., user ID)
      payload = {
        user_id: user.id, 
        exp: (Time.now + 6.hours).to_i
      }
      
      # Encode the token with a secret key (ensure to use a strong secret)
      JWT.encode(payload, Rails.application.secret_key_base, 'HS256') # HS256 is the algorithm
  end
end
  