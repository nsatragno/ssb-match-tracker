#!/usr/bin/ruby

require 'discordrb'
require 'dotenv'

require './lib/characters.rb'
require './lib/database.rb'

REGISTER_COMMAND = '!register '

Dotenv.load

bot = Discordrb::Bot.new token: ENV['BOT_TOKEN']
Discordrb::LOGGER.mode = :normal
Discordrb::LOGGER.fancy = true

db = Database.new

Discordrb::LOGGER.info "ssb-match-tracker loaded!"
Discordrb::LOGGER.info "invite url: #{bot.invite_url()}"

def sanitize_character(text)
  character = text.slice(1..text.size - 2).downcase
  character = ALIASES[character] || character
  CHARACTERS.find do |listed_character|
    listed_character.downcase == character.downcase
  end
end

bot.message(start_with: REGISTER_COMMAND) do |event|
  command = event.message.content.slice(REGISTER_COMMAND.size, event.message.content.size)
  unless command.match? /<@.+> +\(.+?\) +\d-\d +<@.+> +\(.+?\)/ and event.message.mentions.size == 2
    event.respond 'Bad message format, try something like `!register @Kairos (Lucas) 0-3 @eriNa_ (Rosalina & Luma)`'
    next
  end

  left_user = event.message.mentions[0]
  right_user = event.message.mentions[1]

  characters = command.scan(/\(.+?\)/)
  left_character = sanitize_character(characters[0])
  unless left_character
    event.respond "Unrecognized character #{characters[0]}"
    next
  end
  right_character = sanitize_character(characters[1])
  unless right_character
    event.respond "Unrecognized character #{characters[1]}"
    next
  end

  event.respond "Match registered: #{left_user.username} (#{left_character}) vs #{right_user.username} (#{right_character})"
end

bot.run

