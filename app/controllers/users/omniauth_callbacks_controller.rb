class UsersController::OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, raise: false # not needed in API mode
  
    def google_oauth2
      user = User.from_omniauth(request.env['omniauth.auth'])
  
      if user.persisted?
        sign_in(user)
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        render json: { jwt: token }, status: :ok
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
end
  