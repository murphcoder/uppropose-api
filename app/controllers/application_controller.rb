class ApplicationController < ActionController::API
  before_action :authenticate_user

  def current_user
    @current_user
  end

  private

  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last  # Extract token from Authorization header

    if token.present?
      begin
        decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' }) # Decode the token
        user_id = decoded_token[0]['user_id']  # Extract the user_id from the token payload
        @current_user = User.find(user_id)  # Find the user from the database
      rescue JWT::DecodeError => e
        render json: { error: 'Invalid token' }, status: :unauthorized  # Handle invalid token error
      end
    else
      render json: { error: 'Token missing' }, status: :unauthorized  # Handle missing token error
    end
  end
end
