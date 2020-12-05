#!/usr/bin/ruby

require 'discordrb'
require 'dotenv'

require './lib/characters.rb'
require './lib/database.rb'

REGISTER_COMMAND = '!register'
NEW_SEASON_COMMAND = '!new_season'

Dotenv.load

bot = Discordrb::Bot.new token: ENV['BOT_TOKEN']

# Need to reload the logger after creating a bot.
Logging.load

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

def get_arguments(event, command_name)
  event.message.content.slice(command_name.size + 1, event.message.content.size) or ""
end

bot.message(start_with: REGISTER_COMMAND) do |event|
  command = get_arguments(event, REGISTER_COMMAND)
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

bot.message(start_with: NEW_SEASON_COMMAND) do |event|
  name = get_arguments(event, NEW_SEASON_COMMAND).strip
  if name.empty?
    event.respond "The `#{NEW_SEASON_COMMAND}` command requires a name, try `!new_season Amazing Season`"
    next
  end
  event.respond "Season #{name} created!"
end

bot.run

