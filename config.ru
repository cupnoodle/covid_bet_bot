# frozen_string_literal: true

# load environment variables, for config/database.yml use
require 'dotenv'
Dotenv.load('.env', '.env.production')

require 'raven'

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end

use Raven::Rack

root_dir = File.dirname(__FILE__)
app_file = File.join(root_dir, 'app.rb')
require app_file

set :environment, ENV['RACK_ENV'].nil? ? :development : ENV['RACK_ENV'].to_sym
set :root,        root_dir
set :app_file,    app_file
# disable :run


run Sinatra::Application
