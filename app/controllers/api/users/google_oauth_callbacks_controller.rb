class Api::Users::GoogleOauthCallbacksController < ApplicationController
    skip_before_action :authenticate_user
    
    def google_oauth2
      google_auth_code = params[:code]  # Capture the authorization code sent by Google
      
      if google_auth_code.present?
        # Step 1: Exchange the authorization code for an access token
        token_info = exchange_code_for_token(google_auth_code)
  
        if token_info
          # Step 2: Use the access token to fetch user info from Google
          user_info = fetch_user_info_from_google(token_info)
  
          # Step 3: Find or create the user from Google info
          @user = User.from_oauth(user_info)
  
          # Step 4: Generate JWT token if user is found/created
          if @user.persisted?
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
        # Generate JWT payload (e.g., user ID)
        payload = { user_id: user.id }
        
        # Encode the token with a secret key (ensure to use a strong secret)
        JWT.encode(payload, Rails.application.secret_key_base, 'HS256') # HS256 is the algorithm
    end
  
    def exchange_code_for_token(code)
      # Initialize the OAuth2 client with Google credentials and endpoints
      client = OAuth2::Client.new(
        ENV['GOOGLE_CLIENT_ID'], 
        ENV['GOOGLE_CLIENT_SECRET'], 
        site: 'https://accounts.google.com', 
        authorize_url: '/o/oauth2/v2/auth', 
        token_url: '/o/oauth2/token'
      )
  
      # Exchange the authorization code for the access token
      token = client.auth_code.get_token(code, redirect_uri: "#{ENV['FRONTEND_URI']}/google/callback")
      
      # Return the access token (this is used for making requests to Google)
      token.token
    end
  
    def fetch_user_info_from_google(access_token)
        # Step 1: Initialize the OAuth2 client again for making the user info request
        client = OAuth2::Client.new(
          ENV['GOOGLE_CLIENT_ID'], 
          ENV['GOOGLE_CLIENT_SECRET'], 
          site: 'https://www.googleapis.com'
        )
    
        # Step 2: Make the request to fetch user info from Google's API using the access token
        response = client.request(:get, '/oauth2/v2/userinfo', headers: { 'Authorization' => "Bearer #{access_token}" })
    
        # Step 3: Parse and return the user info from the response
        JSON.parse(response.body)
    end
end
  