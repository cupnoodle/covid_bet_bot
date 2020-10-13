require 'telegram/bot'
require 'sinatra'
require 'sinatra/activerecord'
require 'json'


# load environment variables
require 'dotenv'
Dotenv.load('.env', '.env.production')

token = ENV['TELEGRAM_TOKEN']

post "/webhook" do
  status 200
  # Get Telegram Data
  request.body.rewind
  data = JSON.parse(request.body.read)
  
  # Output data on stdout
  p data
  # Return an empty json, to say "ok" to Telegram
  "{}"
end

get '/webhook' do
  'wat'
end

get '/' do
  HOOK_URL = "https://covid.littlefox.es/webhook"
  bot = Telegram::Bot::Api.new(ENV['TELEGRAM_TOKEN'])
  bot.set_webhook(url: HOOK_URL)
end

# r = api.setWebhook("https://covid.littlefox.es/webhook").to_json