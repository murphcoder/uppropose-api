OAuth2::Client.new(
  ENV['GOOGLE_CLIENT_ID'],
  ENV['GOOGLE_CLIENT_SECRET'],
  site: 'https://accounts.google.com',
  authorize_url: 'https://accounts.google.com/o/oauth2/auth',
  token_url: 'https://oauth2.googleapis.com/token'
)