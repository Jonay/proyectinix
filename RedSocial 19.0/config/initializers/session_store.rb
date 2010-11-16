# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_hello_tog_session',
  :secret      => 'c2eca0e639e166debdb8be8ae5806bf38bcbf4998dcb4f104e93e18866d387719eda3d25f2b357b138545bd0a42f6361adcc3fc6589b51701a84e5f415242cfd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
