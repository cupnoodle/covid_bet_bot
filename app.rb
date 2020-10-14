require 'telegram/bot'
require 'sinatra'
require 'sinatra/activerecord'
require "sinatra/reloader" if development?
require 'json'

require './models/poll.rb'
require './models/user.rb'
require './models/vote.rb'

# load environment variables
require 'dotenv'
Dotenv.load('.env', '.env.production')

token = ENV['TELEGRAM_TOKEN']

post "/webhook" do
  bot = Telegram::Bot::Api.new(ENV['TELEGRAM_TOKEN'])
  status 200
  # Get Telegram Data
  request.body.rewind
  data = JSON.parse(request.body.read)
  
  # Output data on stdout
  p data

  message_key = 'message'

  if data.key?('edited_message')
    message_key = 'edited_message'
  end

  # p "chat id"
  # p data['message']['chat']['id'].to_i.abs

  # p 'from id'
  # p data['message']['from']['id'].to_i.abs

  chat_id = data[message_key]['chat']['id'].to_i
  from_id = data[message_key]['from']['id'].to_i
  from_name = data[message_key]['from']['first_name']

  user = User.where(telegram_id: from_id).first_or_create(name: from_name)
  poll = Poll.where(chat_id: chat_id, ended: false).first_or_create

  text = data[message_key]['text']

  p('text from ' + from_name)

  if text.start_with?('/bet')
    num = text.split(' ')[1]

    if num.to_i <= 0
      bot.send_message(chat_id: chat_id, text: "Please specify a positive integer, eg: /bet 123")
    elsif num.to_i > 1_000_000
      bot.send_message(chat_id: chat_id, text: "Please bet a smaller number, lul")
    else
      vote = Vote.where(poll_id: poll.id, user_id: user.id).first_or_create.update(answer: num)

      bot.send_message(chat_id: chat_id, text: "#{user.name} have voted #{num}")

      list = "Current votes : "
      votes = Vote.where(poll_id: poll.id).order(answer: :desc)
      votes.each do |v|
        list += "\n #{v.user.name} = #{v.answer}"
      end

      bot.send_message(chat_id: chat_id, text: list)
    end
  end

  if text.start_with?('/current')
    chat_id = data[message_key]['chat']['id'].to_i
    poll = Poll.where(chat_id: chat_id, ended: false).first

    if poll.nil?
      bot.send_message(chat_id: chat_id, text: "No active poll, please place bet with /bet 123 to begin poll")
    else
      list = "Current votes : "
      votes = Vote.where(poll_id: poll.id).order(answer: :desc)
      votes.each do |v|
        list += "\n #{v.user.name} = #{v.answer}"
      end

      bot.send_message(chat_id: chat_id, text: list)
    end
  end

  if text.start_with?('/answer')
    chat_id = data[message_key]['chat']['id'].to_i
    poll = Poll.where(chat_id: chat_id, ended: false).first

    num = text.split(' ')[1]

    if poll.nil?
      bot.send_message(chat_id: chat_id, text: "No active poll, please place bet with /bet 123 to begin poll")
    else
      
      bot.send_message(chat_id: chat_id, text: "420 smoke weed")
    end
  end

  # Return an empty json, to say "ok" to Telegram
  "{}"
end

get '/webhook' do
  puts "params is "
  puts params
  'wat'
end

get '/setup' do
  HOOK_URL = "https://9db9696b4aca.ngrok.io/webhook"
  bot = Telegram::Bot::Api.new(ENV['TELEGRAM_TOKEN'])
  bot.set_webhook(url: HOOK_URL)
end

get '/' do
  # HOOK_URL = "https://covid.littlefox.es/webhook"
  # bot = Telegram::Bot::Api.new(ENV['TELEGRAM_TOKEN'])
  # bot.set_webhook(url: HOOK_URL)
  # bot.set_my_commands(commands: [ { command: 'bet', description: 'Bet today number of new cases'}, { command: 'result', description: 'Announce today result' }])
  'welp'
end

# r = api.setWebhook("https://covid.littlefox.es/webhook").to_json