class Api::ProtectedResourceController < Api::BaseController
    before_action :authorize_request
  
    def index
      render json: { message: 'This is a protected resource' }
    end
  
    private
  
    def authorize_request
      token = request.headers['Authorization']&.split(' ')&.last
      decoded = decode_token(token)
      @current_user = User.find_by(id: decoded[:user_id]) if decoded
  
      render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user
    end
  
    def decode_token(token)
      JWT.decode(token, Rails.application.secret_key_base)[0] if token
    rescue JWT::DecodeError
      nil
    end
end
  