# app/controllers/api/users/sessions_controller.rb
class Api::Users::SessionsController < ApplicationController
    before_action :authorize_request, only: [:destroy]
  
    # POST /api/users/sign_in
    def create
        user = User.find_by(email: params[:email])
        
        if user && user.authenticate(params[:password])  # Check the password using bcrypt
          token = encode_jwt_token(user)  # Generate a JWT token
          render json: { token: token, user: user }, status: :ok
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
        payload = { user_id: user.id }
        
        # Encode the token with a secret key (ensure to use a strong secret)
        JWT.encode(payload, Rails.application.secret_key_base, 'HS256') # HS256 is the algorithm
    end
  
    def authorize_request
      # This will check the authorization header for a valid token
      token = request.headers['Authorization'].split(' ').last
      decoded = decode_token(token)
      @current_user = User.find_by(id: decoded[:user_id]) if decoded
      render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user
    end
  
    def decode_token(token)
      # Decode the token to extract user data
      begin
        JWT.decode(token, Rails.application.secret_key_base)[0] # Return the payload
      rescue JWT::DecodeError
        nil
      end
    end
end
  