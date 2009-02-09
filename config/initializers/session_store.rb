# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_restaurant_helper_session',
  :secret      => '56a96be08b394963512ffb70b2938976a9bb35a719ce7f168a0818df8c6338a0085c5cb5281709e142e685f0c80267d75a76e5ae54ec2f9299ddd63b00230135'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
