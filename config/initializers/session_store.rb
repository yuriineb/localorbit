# Be sure to restart your server when you modify this file.

session_environment = Rails.env.production? ? '' : "_#{Rails.env}"

session_suffix = Figaro.env.localorbit_internal == 'YES' ? '_INTERNAL' : ''

session_key = "_LocalOrbit_session_data#{session_environment}#{session_suffix}"

# Use .(domain) unless testing:
domain = Rails.env.test? ? nil : ".#{Figaro.env.domain}"

LocalOrbit::Application.config.session_store(:cookie_store, key: session_key, domain: domain)
