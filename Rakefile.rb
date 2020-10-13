# frozen_string_literal: true

# Rakefile

# require dotenv, as database config needs it
require 'dotenv'
Dotenv.load('.env', '.env.production')

require './app.rb'
require 'sinatra/activerecord/rake'
