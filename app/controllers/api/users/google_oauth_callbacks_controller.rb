class Api::Users::GoogleOauthCallbacksController < ApplicationController
    skip_before_action :authenticate_user
    
    def google_oauth2
      google_auth_code = params[:code]
      
      if google_auth_code.present?
        token_info = exchange_code_for_token(google_auth_code)
  
        if token_info
          user_info = fetch_user_info_from_google(token_info)
          
          @user = User.from_oauth(user_info)
  
          if @user.present?
            token = encode_jwt_token(@user)
            render json: { token: token, user: @user, expirationDate: @user.expiration_date, proposalCount: @user.proposals_this_month.count }, status: :ok
          else
            render json: { error: 'Authentication failed' }, status: :unauthorized
          end
        else
          render json: { error: 'Failed to exchange code for token' }, status: :unauthorized
        end
      else
        render json: { error: 'No authorization code provided' }, status: :bad_request
      end
    end
  
    private

    def encode_jwt_token(user)
        payload = { user_id: user.id }
        
        JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
    end
  
    def exchange_code_for_token(code)
      client = OAuth2::Client.new(
        ENV['GOOGLE_CLIENT_ID'], 
        ENV['GOOGLE_CLIENT_SECRET'], 
        site: 'https://accounts.google.com', 
        authorize_url: '/o/oauth2/v2/auth', 
        token_url: '/o/oauth2/token'
      )
  
      token = client.auth_code.get_token(code, redirect_uri: "#{ENV['FRONTEND_URI']}/google/callback")
      
      token.token
    end
  
    def fetch_user_info_from_google(access_token)
        client = OAuth2::Client.new(
          ENV['GOOGLE_CLIENT_ID'], 
          ENV['GOOGLE_CLIENT_SECRET'], 
          site: 'https://www.googleapis.com'
        )
    
        response = client.request(:get, '/oauth2/v2/userinfo', headers: { 'Authorization' => "Bearer #{access_token}" })
    
        JSON.parse(response.body)
    end
end
  