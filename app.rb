require 'telegram/bot'
require 'sinatra'
require 'sinatra/activerecord'
require "sinatra/reloader" if development?
require 'json'

require './models/poll.rb'
require './models/user.rb'
require './models/vote.rb'
require './models/median.rb'

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

  if text.nil?
    bot.send_message(chat_id: chat_id, text: "This bot can't be used in secret group")
    return "{}"
  end

  if text.start_with?('/kevin')
    quotes = [
      'Yeah man',
      'Gotta work harder',
      'Hoping for my next home run',
      'If only I can get a team...',
      'If only I can get a big project...',
      'How lah like that',
      'These investors dont believe in me, how?',
      'Malaysia client and company too stingy',
      'Weekly Java study session when',
      "I'm now streaming on Twitch! Playing PLAYERUNKNOWN'S BATTLEGROUNDS",
      "I'm now streaming on Twitch! Playing PLAYERUNKNOWN'S BATTLEGROUNDS",
      "I'm now streaming on Twitch! Playing PLAYERUNKNOWN'S BATTLEGROUNDS",
      'I can use it to my advantage.',
      'Gonna eat chap fan',
      'Koh Samui is so nice'
    ]

    bot.send_message(chat_id: chat_id, text: quotes.sample)
    return '{}'
  end

  if text.start_with?('/bet')
    num = text.split(' ')[1]

    if num == 'cancel'
      Vote.where(poll_id: poll.id, user_id: user.id).first&.destroy
      bot.send_message(chat_id: chat_id, text: "#{user.name} have removed bet 💸")

      list = "Current bets : "
      votes = Vote.where(poll_id: poll.id).order(answer: :desc)
      total = 0
      votes.each do |v|
        list += "\n #{v.user.name} = #{v.answer}"
        total += v.answer
      end

      median = votes.map(&:answer).median

      list += "\n\n Mean: #{ total / votes.count }"
      list += "\n Median: #{ median }"
      bot.send_message(chat_id: chat_id, text: list)

      return '{}'
    end

    if num.to_i <= 0
      bot.send_message(chat_id: chat_id, text: "Please specify a positive integer, eg: /bet 123")
    elsif num.to_i > 1_000_000
      bot.send_message(chat_id: chat_id, text: "Please bet a smaller number, lul")
    else
      vote = Vote.where(poll_id: poll.id, user_id: user.id).first_or_create.update(answer: num)

      bot.send_message(chat_id: chat_id, text: "#{user.name} have bet #{num} 🤑")

      list = "Current bets : "
      votes = Vote.where(poll_id: poll.id).order(answer: :desc)

      total = 0
      votes.each do |v|
        list += "\n #{v.user.name} = #{v.answer}"
        total += v.answer
      end

      median = votes.map(&:answer).median

      list += "\n\n Mean: #{ total / votes.count }"
      list += "\n Median: #{ median }"
      bot.send_message(chat_id: chat_id, text: list)
    end
  end

  if text.start_with?('/current')
    chat_id = data[message_key]['chat']['id'].to_i
    poll = Poll.where(chat_id: chat_id, ended: false).first

    if poll.nil?
      bot.send_message(chat_id: chat_id, text: "No active poll, please place bet with /bet 123 to begin poll")
      return '{}'
    else
      list = "Current bets : "
      votes = Vote.where(poll_id: poll.id).order(answer: :desc)

      total = 0
      votes.each do |v|
        list += "\n #{v.user.name} = #{v.answer}"
        total += v.answer
      end

      median = votes.map(&:answer).median

      list += "\n\n Mean: #{ total / votes.count }"
      list += "\n Median: #{ median }"
      bot.send_message(chat_id: chat_id, text: list)
    end
  end

  if text.start_with?('/answer')
    chat_id = data[message_key]['chat']['id'].to_i
    poll = Poll.where(chat_id: chat_id, ended: false).first

    num = text.split(' ')[1]

    if num.to_i <= 0
      bot.send_message(chat_id: chat_id, text: "Please specify positive integer for answer")
      # Return an empty json, to say "ok" to Telegram
      return "{}"
    end

    if poll.nil?
      bot.send_message(chat_id: chat_id, text: "No active poll, please place bet with /bet 123 to begin poll")
      return '{}'
    elsif poll.votes.empty?
      bot.send_message(chat_id: chat_id, text: "No active poll, please place bet with /bet 123 to begin poll")
      return '{}'
    else
      votes_array = []
      poll.votes.each do |v|
        votes_array << { name: v.user.name, answer: v.answer, distance: (v.answer - num.to_i).abs }
      end

      votes_array.sort_by! { |va| va[:distance] }

      shortest_distance = votes_array[0][:distance]

      winners = votes_array.select { |va| va[:distance] == shortest_distance }

      msg = "🎉 Winner: "
      winners.each do |w|
        msg += "\n #{w[:name]} bet #{w[:answer]}"
      end

      msg += "\n Actual new cases today: #{num.to_i}"

      poll.update(correct_answer: num.to_i, ended: true)
      bot.send_message(chat_id: chat_id, text: msg)
    end
  end

  # Return an empty json, to say "ok" to Telegram
  "{}"
end

get '/webhook' do
  'wat'
end

get '/setup' do
  HOOK_URL = "https://covid.littlefox.es/webhook"
  # HOOK_URL = "https://8d314cc99de3.ngrok.io/webhook"
  bot = Telegram::Bot::Api.new(ENV['TELEGRAM_TOKEN'])
  bot.set_webhook(url: HOOK_URL)
  'webhook setup-ed'
end

get '/' do
  # HOOK_URL = "https://covid.littlefox.es/webhook"
  # bot = Telegram::Bot::Api.new(ENV['TELEGRAM_TOKEN'])
  # bot.set_webhook(url: HOOK_URL)
  # bot.set_my_commands(commands: [ { command: 'bet', description: 'Bet today number of new cases'}, { command: 'result', description: 'Announce today result' }])
  'welp'
end

# r = api.setWebhook("https://covid.littlefox.es/webhook").to_json