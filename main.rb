#!/usr/bin/ruby

require 'discordrb'
require 'dotenv'

REGISTER_COMMAND = '!register '

Dotenv.load

# Discordrb::LOGGER = Discordrb::LOGGER.initialize(fancy: true)
bot = Discordrb::Bot.new token: ENV['BOT_TOKEN']
Discordrb::LOGGER.mode = :normal
Discordrb::LOGGER.fancy = true

Discordrb::LOGGER.info "ssb-match-tracker loaded!"
Discordrb::LOGGER.info "invite url: #{bot.invite_url()}"

bot.message(start_with: REGISTER_COMMAND) do |event|
  command = event.message.content.slice(REGISTER_COMMAND.size, event.message.content.size)
  unless command.match? /<@.+> +\(.+?\) +\d-\d +<@.+> +\(.+?\)/ and event.message.mentions.size == 2
    event.respond 'Bad message format, try something like `@Kairos (Lucas) 0-3 @eriNa_ (Rosalina & Luma)`'
    return
  end

  left_user = event.message.mentions[0]
  right_user = event.message.mentions[1]

  event.respond "Match registered: #{left_user.username} vs #{right_user.username}"
end

bot.run
