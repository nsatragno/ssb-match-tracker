#!/usr/bin/ruby

require 'discordrb'
require 'dotenv'

REGISTER_COMMAND = '!register '

Dotenv.load

bot = Discordrb::Bot.new token: ENV['BOT_TOKEN']

bot.message(start_with: REGISTER_COMMAND) do |event|
  command = event.message.content.slice(REGISTER_COMMAND.size, event.message.content.size)
  unless command.match? /.+? \(.+?\) \d-\d .+? \(.+?\)/
    event.respond 'Bad message format, try something like `Kairos (Lucas) 0-3 eriNa_ (Rosalina & Luma)`'
    return
  end

  users = event.channel.users

  # match everything up to the first (
  left_user = command[/.+? \(/]
  left_user.slice!(left_user.size - 1..left_user.size)
  left_user.strip!

  # first isolate the text after the score
  right_text = command[/.+? \(.+?\) \d-\d /]
  # then match everything up to the first (
  right_user = command.slice(right_text.size..command.size)[/.+? \(/]
  right_user.slice!(right_user.size - 1..right_user.size)
  right_user.strip!

  event.respond "Match registered: #{left_user} vs #{right_user}"
end

bot.run
